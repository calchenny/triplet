//
//  OverviewViewModel.swift
//  Triplet
//
//  Created by Derek Ma on 2/22/24.
//

import FirebaseFirestore
import SwiftUI
import MapKit

class OverviewViewModel: ObservableObject {
    @Published var trip: Trip?
    @Published var notes: [Note] = []
    @Published var housing: [Event] = []
    @Published var food: [Event] = []
    
    @Published var cameraPosition: MapCameraPosition?
    @Published var toggleStates = ToggleStates()
    @Published var showAlert: Bool = false
    @Published var newNoteTitle: String = ""
    @Published var validationError: String = ""
    @Published var collapseProgress: CGFloat = 0
    @Published var showFoodPopup: Bool = false
    @Published var showHousingPopup: Bool = false
    
    private var db = Firestore.firestore()
    private var listenerRegistrations: [ListenerRegistration] = []
    
    let minHeight: CGFloat = 150.0
    let maxHeight: CGFloat = 300.0

    func addNote() {
        guard !newNoteTitle.isEmpty else {
            print("Note name must be non-empty")
            return
        }
        guard let trip else {
            print("Missing trip")
            return
        }
        guard let tripId = trip.id else {
            print("Missing tripId")
            return
        }
        do {
            try db.collection("trips/\(tripId)/notes").addDocument(from: Note(title: newNoteTitle))
            newNoteTitle = ""
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addFoodPlace(name: String, location: GeoPoint, address: String, foodCategory: FoodCategory) {
        guard let trip else {
            print("Missing trip")
            return
        }
        guard let tripId = trip.id else {
            print("Missing tripId")
            return
        }
        let foodPlace = Event(name: name,
                              location: location,
                              type: EventType.food,
                              category: foodCategory,
                              start: Date.now,
                              address: address,
                              end: Date.now)
        do {
            try db.collection("trips/\(tripId)/events").addDocument(from: foodPlace)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateNote(noteId: String, content: String) {
        guard let trip else {
            print("Missing trip")
            return
        }
        guard let tripId = trip.id else {
            print("Missing tripId")
            return
        }
        let noteRef = db.document("trips/\(tripId)/notes/\(noteId)")
        noteRef.updateData(["content": content]) { error in
            if let error {
                print(error.localizedDescription)
            } else {
                print("Updated note")
            }
        }
    }

    func unsubscribe() {
        if !listenerRegistrations.isEmpty {
            listenerRegistrations.forEach { listenerRegistration in
                listenerRegistration.remove()
            }
            listenerRegistrations = []
        }
    }
    
    func subscribe(tripId: String) {
        if listenerRegistrations.isEmpty {
            let tripQuery = db.document("trips/\(tripId)")
            listenerRegistrations.append(tripQuery.addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                  print("Error fetching document: \(error!)")
                  return
                }
                do {
                    let trip = try document.data(as: Trip.self)
                    self.trip = trip
                    self.cameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: trip.destination.latitude, longitude: trip.destination.longitude), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
                } catch {
                    print(error)
                }
            })
            
            let notesQuery = db.collection("trips/\(tripId)/notes")
            listenerRegistrations.append(notesQuery.addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                withAnimation {
                    self.notes = documents.compactMap { queryDocumentSnapshot in
                        try? queryDocumentSnapshot.data(as: Note.self)
                    }
                }
            })
            
            let housingQuery = db.collection("trips/\(tripId)/events").whereField("type", isEqualTo: EventType.housing.rawValue)
            listenerRegistrations.append(housingQuery.addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                withAnimation {
                    self.housing = documents.compactMap { queryDocumentSnapshot in
                        try? queryDocumentSnapshot.data(as: Event.self)
                    }
                }
            })
            
            let foodQuery = db.collection("trips/\(tripId)/events").whereField("type", isEqualTo: EventType.food.rawValue)
            listenerRegistrations.append(foodQuery.addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                withAnimation {
                    self.food = documents.compactMap { queryDocumentSnapshot in
                        try? queryDocumentSnapshot.data(as: Event.self)
                    }
                }
            })
        }
    }
}

struct FoodToggleStates {
    var all: Bool = true
    var breakfast: Bool = true
    var lunch: Bool = true
    var dinner: Bool = true
}

struct ToggleStates {
    var notes: Bool = true
    var housing: Bool = true
    var food: FoodToggleStates = FoodToggleStates()
}

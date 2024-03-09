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
    @Published var trip: Trip
    @Published var notes: [Note] = []
    @Published var housing: [Event] = []
    
    @Published var cameraPosition: MapCameraPosition
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
    
    init(trip: Trip) {
        self.trip = trip
        self.cameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: trip.destination.latitude, longitude: trip.destination.longitude), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
    }
    
    func addNote() {
        guard !newNoteTitle.isEmpty else {
            print("Note name must be non-empty")
            return
        }
        guard let tripId = trip.id else {
            print("Missing tripId")
            return
        }
        do {
            try Firestore.firestore().collection("trips/\(tripId)/notes").addDocument(from: Note(title: newNoteTitle))
            newNoteTitle = ""
        } catch {
            print(error)
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
    
    func subscribe() {
        if listenerRegistrations.isEmpty {
            guard let tripId = trip.id else {
                print("Missing tripId")
                return
            }
            let notesQuery = db.collection("trips/\(tripId)/notes")
            listenerRegistrations.append(notesQuery.addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                self.notes = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: Note.self)
                }
            })
            
            let housingQuery = db.collection("trips/\(tripId)/events").whereField("type", isEqualTo: EventType.housing)
            listenerRegistrations.append(housingQuery.addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                self.housing = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: Event.self)
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

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
    @Published var notes: [Note] = []
    @Published var housing: [Event] = []
    @Published var food: [Event] = []
    @Published var toggleStates = ToggleStates()
    @Published var showAlert: Bool = false
    @Published var newNoteTitle: String = ""
    @Published var validationError: String = ""
    @Published var showFoodPopup: Bool = false
    @Published var showHousingPopup: Bool = false
    
    private var db = Firestore.firestore()
    private var listenerRegistrations: [ListenerRegistration] = []
    
    let minHeight: CGFloat = 150.0
    let maxHeight: CGFloat = 300.0

    func addNote(tripId: String) {
        do {
            try db.collection("trips/\(tripId)/notes").addDocument(from: Note(title: newNoteTitle))
            newNoteTitle = ""
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addFoodPlace(name: String, location: GeoPoint, address: String, start: Date, foodCategory: FoodCategory, tripId: String) {
        let foodPlace = Event(name: name,
                              location: location,
                              type: EventType.food,
                              category: foodCategory,
                              start: start,
                              address: address,
                              end: start + 60 * 60)
        do {
            try db.collection("trips/\(tripId)/events").addDocument(from: foodPlace)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addHousingPlace(name: String, location: GeoPoint, address: String, start: Date, end: Date, tripId: String) {
        let housingPlace = Event(name: name,
                              location: location,
                              type: EventType.housing,
                              start: start,
                              address: address,
                              end: end)
        do {
            try db.collection("trips/\(tripId)/events").addDocument(from: housingPlace)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateNote(noteId: String, title: String, content: String, tripId: String) {
        let noteRef = db.document("trips/\(tripId)/notes/\(noteId)")
        noteRef.updateData(["title": title, "content": content]) { error in
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

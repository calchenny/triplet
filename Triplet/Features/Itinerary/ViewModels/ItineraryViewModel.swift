//
//  ItineraryModel.swift
//  Triplet
//
//  Created by Andy Lam on 2/28/24.
//

import SwiftUI
import EventKit
import ScalingHeaderScrollView
import MapKit
import FirebaseFirestore

class ItineraryViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var showNewPlacePopUp: Bool = false
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    // Function to sort events by date and time
    func sortEvents() {
        events.sort { $0.start < $1.start }
    }
    
    func addEventToFirestore(_ event: Event, tripId: String) {
        do {
            let eventReference = try Firestore.firestore().collection("trips").document(tripId).collection("events").addDocument(from: event)
            print("Event added to Firestore with ID: \(eventReference.documentID)")
        } catch {
            print("Error adding event to Firestore: \(error.localizedDescription)")
        }
    }

    // Function to add an event to both Firestore and the local events array
    func addEvent(name: String, location: GeoPoint, type: EventType, category: FoodCategory?, start: Date, address: String, end: Date, tripId: String) {
        // Create a new Event instance
        let newEvent = Event(
            id: nil,
            name: name,
            location: location,
            type: type,
            category: nil,
            start: start,
            address: address,
            end: end
        )

        // Add the new event to Firestore
        addEventToFirestore(newEvent, tripId: tripId)
    }
    
    
    func deleteEventFromFirestore(eventID: String, tripId: String) {
        let eventReference = db.collection("trips").document(tripId).collection("events").document(eventID)
        
        eventReference.delete { error in
            if let error = error {
                print("Error deleting event from Firestore: \(error.localizedDescription)")
            } else {
                print("Event deleted from Firestore")
            }
        }
    }
    
    func subscribe(tripId: String) {
        if listenerRegistration == nil {
            let eventsQuery = db.collection("trips/\(tripId)/events")
            listenerRegistration = eventsQuery.addSnapshotListener { collectionSnapshot, error in
                switch (collectionSnapshot, error) {
                case (.none, .none):
                    print("No events found")
                case (.none, .some(let error)):
                    print("Error: \(error.localizedDescription)")
                case (.some(let collection), _):
                    withAnimation {
                        self.events = collection.documents.compactMap { document in
                            try? document.data(as: Event.self)
                        }
                        self.sortEvents()
                    }
                }
            }
        }
    }
    
    func unsubscribe() {
        if listenerRegistration != nil {
            listenerRegistration?.remove()
            listenerRegistration = nil
        }
    }
}

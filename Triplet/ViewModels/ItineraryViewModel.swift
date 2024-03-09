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
    var tripId: String = "Placeholder tripId"
    @Published var events: [Event] = []
//    @Published var trip: Trip
    
    @Published var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 47.608013, longitude: -122.335167), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
    
    @Published var collapseProgress: CGFloat = 0
    
    let minHeight: CGFloat = 100.0
    let maxHeight: CGFloat = 250.0
    
    // Function to sort events by date and time
    func sortEvents() {
        events.sort { $0.start < $1.start }
    }
    
    func addEventToFirestore(_ event: Event) {
        do {
            let eventReference = try Firestore.firestore().collection("trips").document(tripId).collection("events").addDocument(from: event)
            print("Event added to Firestore with ID: \(eventReference.documentID)")
        } catch {
            print("Error adding event to Firestore: \(error.localizedDescription)")
        }
    }

    // Function to add an event to both Firestore and the local events array
    func addEvent(name: String, location: GeoPoint, type: EventType, category: FoodCategory?, start: Date, address: String, end: Date) {
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
        addEventToFirestore(newEvent)
    }
    
    func fetchEvents() {
        Firestore.firestore().collection("trips").document(tripId).collection("events").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching events: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Map Firestore documents to Event objects
            let fetchedEvents = documents.compactMap { document -> Event? in
                do {
                    return try document.data(as: Event.self)
                } catch {
                    print("Error decoding event: \(error.localizedDescription)")
                    return nil
                }
            }

            // Update the local events array
            self.events = fetchedEvents
            self.sortEvents()
        }
    }

    func formatDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd" // Customize the format as needed
        print("Start date: \(dateFormatter.string(from: date))")
    }

    func deleteEvent(at index: Int) {
        events.remove(at: index)
    }
    
}

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
    @Published var trip: Trip?
    @Published var events: [Event] = []
    @Published var cameraPosition: MapCameraPosition?

    @Published var collapseProgress: CGFloat = 0
    
    let minHeight: CGFloat = 150.0
    let maxHeight: CGFloat = 300.0
    
    private var db = Firestore.firestore()
    private var listenerRegistrations: [ListenerRegistration] = []
    
    // Function to sort events by date and time
    func sortEvents() {
        events.sort { $0.start < $1.start }
    }
    
    func addEventToFirestore(_ event: Event) {
        guard let trip else {
            print("Missing trip")
            return
        }
        guard let tripId = trip.id else {
            print("Missing tripId")
            return
        }
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
    
    
    func deleteEventFromFirestore(eventID: String) {
        guard let trip else {
            print("Missing trip")
            return
        }
        guard let tripId = trip.id else {
            print("Missing tripId")
            return
        }
        
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
            if listenerRegistrations.isEmpty {
                guard !tripId.isEmpty else {
                    print("Missing tripId")
                    return
                }
                let eventsQuery = db.collection("trips/\(tripId)/events")
                listenerRegistrations.append(eventsQuery.addSnapshotListener { (querySnapshot, error) in
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
                    
                    withAnimation {
                        // Update the local events array
                        self.events = fetchedEvents
                        self.sortEvents()
                    }
                })
                
                let tripQuery = db.document("trips/\(tripId)")
                listenerRegistrations.append(tripQuery.addSnapshotListener { documentSnapshot, error in
                    guard let document = documentSnapshot else {
                      print("Error fetching document: \(error!)")
                      return
                    }
                    do {
                        let trip = try document.data(as: Trip.self)
                        withAnimation {
                            self.trip = trip
                            self.cameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: trip.destination.latitude, longitude: trip.destination.longitude), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
                        }
                    } catch {
                        print(error)
                    }
                })
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
    
    func formatDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd" // Customize the format as needed
        print("Start date: \(dateFormatter.string(from: date))")
    }

    
}

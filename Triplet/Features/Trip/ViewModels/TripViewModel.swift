//
//  TripViewModel.swift
//  Triplet
//
//  Created by Derek Ma on 3/15/24.
//

import SwiftUI
import Firebase
import MapKit

class TripViewModel: ObservableObject {
    @Published var trip: Trip?
    @Published var cameraPosition: MapCameraPosition?
    @Published var headerCollapseProgress: CGFloat = 0
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    let headerMinHeight: CGFloat = 165.0
    let headerMaxHeight: CGFloat = 300.0
    
    func deleteTrip() {
        guard let trip else {
            print("Missing trip")
            return
        }
        guard let tripId = trip.id else {
            print("Missing tripId")
            return
        }
        let tripRef = db.document("trips/\(tripId)")
        tripRef.delete { error in
            guard let error else {
                print("Trip deleted successfully")
                return
            }
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func subscribe(tripId: String) {
        if listenerRegistration == nil {
            let tripQuery = db.document("trips/\(tripId)")
            listenerRegistration = tripQuery.addSnapshotListener { documentSnapshot, error in
                switch (documentSnapshot, error) {
                case (.none, .none):
                    print("No trip found")
                case (.none, .some(let error)):
                    print("Error: \(error.localizedDescription)")
                case (.some(let document), _):
                    do {
                        let trip = try document.data(as: Trip.self)
                        print("Trip loaded successfully")
                        withAnimation {
                            self.trip = trip
                            
                            let latitude = trip.destination.latitude
                            let longitude = trip.destination.longitude
                            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                            let region = MKCoordinateRegion(center: center, span: span)
                            
                            self.cameraPosition = MapCameraPosition.region(region)
                        }
                    } catch {
                        print("Error: \(error.localizedDescription)")
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

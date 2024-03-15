//
//  TripViewModel.swift
//  Triplet
//
//  Created by Derek Ma on 3/15/24.
//

import Firebase
import SwiftUI

class TripViewModel: ObservableObject {
    @Published var trip: Trip?
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
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
                        print("Trip loaded")
                        withAnimation {
                            self.trip = trip
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

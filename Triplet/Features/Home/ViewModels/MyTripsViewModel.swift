//
//  MyTripsViewModel.swift
//  Triplet
//
//  Created by Derek Ma on 2/29/24.
//

import Firebase
import SwiftUI


class MyTripsViewModel: ObservableObject {
    @Published var currentTrips: [Trip] = []
    @Published var pastTrips: [Trip] = []
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var tripIDs: Set<String> = []
    
    func unsubscribe(completion: (() -> Void)?) {
        if listenerRegistration != nil {
            listenerRegistration?.remove()
            listenerRegistration = nil
            completion?()
        }
    }

    func subscribe(completion: (() -> Void)?) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Missing user")
            return
        }
        
        if listenerRegistration == nil {
            let tripsQuery = db.collection("trips").whereField("owner", isEqualTo: uid)

            listenerRegistration = tripsQuery.addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                let trips = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: Trip.self)
                }
                
                self.currentTrips = trips.filter { $0.end > Date() }
                self.pastTrips = trips.filter { $0.end <= Date() }
                
                completion?()
            }
        }
    }
}

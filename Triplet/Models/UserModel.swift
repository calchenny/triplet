//
//  UserModel.swift
//  Triplet
//
//  Created by Derek Ma on 2/29/24.
//

import FirebaseFirestore
import SwiftUI
import FirebaseFirestoreSwift

class UserModel: ObservableObject {
    @Published var uid: String?
    @Published var trips: [Trip] = []
    @Published var currentTrips: [Trip] = []
    @Published var pastTrips: [Trip] = []
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var tripIDs: Set<String> = []
    
    func setUid(uid: String) {
        self.uid = uid
    }
    
    func unsubscribe() {
        if listenerRegistration != nil {
            listenerRegistration?.remove()
            listenerRegistration = nil
        }
    }

    func subscribe() {
        if listenerRegistration == nil {
            guard let uid else {
                print("Missing uid")
                return
            }

            let tripsQuery = db.collection("trips").whereField("owner", isEqualTo: uid)

            listenerRegistration = tripsQuery.addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                self.trips = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: Trip.self)
                }
                
                let currentDate = Date()
                // Load the trip into past & upcoming trip array
                DispatchQueue.main.async {
                    self.trips.sort { (object1, object2) -> Bool in
                        if let start1 = object1.start, let start2 = object2.start {
                            return start1 < start2
                        } else if object1.start != nil && object2.start == nil {
                            return true
                        } else {
                            return false
                        }
                    }
                    self.currentTrips = []
                    self.pastTrips = []
                    for trip in self.trips {
                        guard let end = trip.end else {
                            print("Unable to get start date")
                            return
                        }
                        if (end > currentDate) {
                            self.currentTrips.append(trip)
                        } else {
                            self.pastTrips.append(trip)
                        }
                    }
                }
            }
        }
    }
}

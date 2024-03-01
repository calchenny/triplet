//
//  UserModel.swift
//  Triplet
//
//  Created by Derek Ma on 2/29/24.
//

import FirebaseFirestore
import SwiftUI

class UserModel: ObservableObject {
    @Published var uid: String?
    @Published var trips: [Trip] = []
    
    func setUid(uid: String) {
        self.uid = uid
    }
    
    func fetchTrips() {
        guard let uid else {
            print("Missing uid")
            return
        }
        let tripsRef = Firestore.firestore().collection("Trips")
        let tripQuery = tripsRef.whereField("owner", isEqualTo: uid)
        tripQuery.addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            self.trips = documents.compactMap { queryDocumentSnapshot -> Trip? in
                return try? queryDocumentSnapshot.data(as: Trip.self)
            }
        }
    }
}

//
//  UserModel.swift
//  Triplet
//
//  Created by Derek Ma on 2/29/24.
//

import FirebaseFirestore
import SwiftUI

class UserModel: ObservableObject {
    @Published var uid: String = ""
    @Published var trips: [Trip] = []
    private var tripsRef = Firestore.firestore().collection("Trips")
    
    func setUid(uid: String) {
        self.uid = uid
    }
    
    func loadTrips(uid: String) async {
        let tripQuery = tripsRef.whereField("owner", isEqualTo: self.uid)
        do {
            let querySnapshot = try await tripQuery.getDocuments()
            self.trips = querySnapshot.documents.compactMap({ queryDocumentSnapshot -> Trip? in
                return try? queryDocumentSnapshot.data(as: Trip.self)
            })
        } catch {
            print("Error getting documents: \(error)")
        }
    }
}

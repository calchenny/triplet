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
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    func setUid(uid: String) {
        self.uid = uid
    }
    
    private func fetchTrip(documentId: String) {
        let docRef = db.collection("trips").document(documentId)
        docRef.getDocument(as: Trip.self) { result in
          switch result {
          case .success(let trip):
            // A trip value was successfully initialized from the DocumentSnapshot.
              self.trips.append(trip)
          case .failure(let error):
            // A Trip value could not be initialized from the DocumentSnapshot.
            print("Error decoding document: \(error.localizedDescription)")
          }
        }
    }
  
    func loadingUserData() async {
        do {
            guard let uid else {
                print("Missing uid")
                return
            }
            let docRef = try await db.collection("trips").whereField("owner", isEqualTo: uid)
                .getDocuments()
            for document in docRef.documents {
                fetchTrip(documentId: document.documentID)
            }
            print(self.trips)
        } catch {
            print("Error getting documents")
        }
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

            let tripQuery = db.collection("trips").whereField("owner", isEqualTo: uid)

            listenerRegistration = tripQuery.addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                self.trips = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: Trip.self)
                }
            }
        }
    }
}

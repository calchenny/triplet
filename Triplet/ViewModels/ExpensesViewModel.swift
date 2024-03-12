//
//  ExpensesViewModel.swift
//  Triplet
//
//  Created by Newland Luu on 3/9/24.
//

import SwiftUI
import EventKit
import ScalingHeaderScrollView
import MapKit
import FirebaseFirestore

class ExpensesViewModel: ObservableObject {
    var tripId: String = "Placeholder tripId"
    @Published var expenses: [Expense] = []

    @Published var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 47.608013, longitude: -122.335167), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))

    @Published var collapseProgress: CGFloat = 0

    let minHeight: CGFloat = 100.0
    let maxHeight: CGFloat = 250.0
    
    func addExpenseToFirestore(_ expense: Expense) {
        do {
            let eventReference = try Firestore.firestore().collection("trips").document(tripId).collection("expenses").addDocument(from: expense)
            print("Event added to Firestore with ID: \(eventReference.documentID)")
        } catch {
            print("Error adding event to Firestore: \(error.localizedDescription)")
        }
    }
    
    func addExpense(name: String, date: Date, category: String, cost: Double) {
        let newExpense = Expense(
            id: nil,
            name: name,
            date: date,
            category: category,
            cost: cost
            )
        
        // Add the new event to Firestore
        addExpenseToFirestore(newExpense)
        
    }

}

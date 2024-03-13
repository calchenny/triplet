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
    @Published var budget: Double = 10000.00
    @Published var currentTotal: Double = 0.00
    @Published var percentage: Double = 0.00

    @Published var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 47.608013, longitude: -122.335167), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))

    @Published var collapseProgress: CGFloat = 0

    let minHeight: CGFloat = 150.0
    let maxHeight: CGFloat = 300.0
    
    private var db = Firestore.firestore()
    private var listenerRegistrations: [ListenerRegistration] = []
    
    func calculateTotal () -> Double {
        print("inside calculateTotal")
        return self.expenses.reduce(0.0) { $0 + $1.cost }
        }
    
    func calculatePercentage () -> Double {
        print("inside calculatePercentage")
        return self.currentTotal/self.budget
    }
    
    func addExpenseToFirestore(_ expense: Expense) {
        do {
            let expenseReference = try Firestore.firestore().collection("trips").document(tripId).collection("expenses").addDocument(from: expense)
            print("Expense added to Firestore with ID: \(expenseReference.documentID)")
        } catch {
            print("Error adding expense to Firestore: \(error.localizedDescription)")
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
        
        // Add the new expense to Firestore
        addExpenseToFirestore(newExpense)
        
    }
    
    func subscribe() {
        if listenerRegistrations.isEmpty {
            
            guard !tripId.isEmpty else {
                print("Missing tripId")
                return
            }
            
            let expensesQuery = db.collection("trips/\(tripId)/expenses")
                
            listenerRegistrations.append(expensesQuery.addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                              print("Error fetching expenses: \(error?.localizedDescription ?? "Unknown error")")
                              return
                          }
                
            // Map Firestore documents to Expense objects
                  let fetchedExpenses = documents.compactMap { document -> Expense? in
                      do {
                          return try document.data(as: Expense.self)
                      } catch {
                          print("Error decoding espense: \(error.localizedDescription)")
                          return nil
                      }
                  }
            
            // Update the local expenses array
                    self.expenses = fetchedExpenses
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

}

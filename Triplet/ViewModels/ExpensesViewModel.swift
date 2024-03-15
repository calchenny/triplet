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
    //var tripId: String = "Placeholder tripId"
    @Published var trip: Trip?
    @Published var expenses: [Expense] = []
    @Published var budget: Double = 10000.00
    @Published var currentTotal: Double = 0.00
    @Published var percentage: Double = 0.00
    @Published var showNewExpensePopup: Bool = false

    @Published var cameraPosition: MapCameraPosition?

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
        guard let trip else {
            print("Missing trip")
            return
        }
        guard let tripId = trip.id else {
            print("Missing tripId")
            return
        }
        
        do {
            let expenseReference = try Firestore.firestore().collection("trips").document(tripId).collection("expenses").addDocument(from: expense)
            print("Expense added to Firestore with ID: \(expenseReference.documentID)")
        } catch {
            print("Error adding expense to Firestore: \(error.localizedDescription)")
        }
    }
    
    func addExpense(name: String, date: Date, category: ExpenseCategory, cost: Double) {
        let newExpense = Expense(
            id: nil,
            name: name,
            date: date,
            category: category,
            cost: cost
            )
        
        // Add the new expense to Firestore
        addExpenseToFirestore(newExpense)
        showNewExpensePopup.toggle()
    }
    
    func subscribe(tripId: String) {
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
                withAnimation {
                    self.expenses = fetchedExpenses
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

}

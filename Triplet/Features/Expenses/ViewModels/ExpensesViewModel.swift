//
//  ExpensesViewModel.swift
//  Triplet
//
//  Created by Newland Luu on 3/9/24.
//

import SwiftUI
import EventKit
import ScalingHeaderScrollView
import FirebaseFirestore

class ExpensesViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var budget: Double = 10000.00
    @Published var currentTotal: Double = 0.00
    @Published var percentage: Double = 0.00
    @Published var showNewExpensePopup: Bool = false
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    func calculateTotal () -> Double {
        print("inside calculateTotal")
        return self.expenses.reduce(0.0) { $0 + $1.cost }
    }
    
    func calculatePercentage () -> Double {
        print("inside calculatePercentage")
        return self.currentTotal/self.budget
    }
    
    func addExpenseToFirestore(_ expense: Expense, tripId: String) {
        do {
            let expenseReference = try db.collection("trips/\(tripId)/expenses").addDocument(from: expense)
            print("Expense added to Firestore with ID: \(expenseReference.documentID)")
        } catch {
            print("Error adding expense to Firestore: \(error.localizedDescription)")
        }
    }
    
    func addExpense(name: String, date: Date, category: ExpenseCategory, cost: Double, tripId: String) {
        let expense = Expense(name: name, date: date, category: category, cost: cost)
        
        // Add the new expense to Firestore
        addExpenseToFirestore(expense, tripId: tripId)
        showNewExpensePopup.toggle()
    }
    
    func subscribe(tripId: String) {
        if listenerRegistration == nil {
            let expensesQuery = db.collection("trips/\(tripId)/expenses")
            listenerRegistration = expensesQuery.addSnapshotListener { collectionSnapshot, error in
                switch (collectionSnapshot, error) {
                case (.none, .none):
                    print("No expenses found")
                case (.none, .some(let error)):
                    print("Error: \(error.localizedDescription)")
                case (.some(let collection), _):
                    withAnimation {
                        self.expenses = collection.documents.compactMap { document in
                            try? document.data(as: Expense.self)
                        }
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

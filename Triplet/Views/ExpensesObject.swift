//
//  ExpensesObject.swift
//  Triplet
//
//  Created by Newland Luu on 2/20/24.
//

import Foundation

class Expense: ObservableObject {
    @Published var id = UUID()
    @Published var expenseName: String
    @Published var cost: String
    @Published var date: Date
    @Published var category: String
    
    init(expenseName: String, cost: String, date: Date, category: String) {
        self.expenseName = expenseName
        self.cost = cost
        self.date = date
        self.category = category
    }
    
    
}

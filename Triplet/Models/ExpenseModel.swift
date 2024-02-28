//
//  ExpensesObject.swift
//  Triplet
//
//  Created by Newland Luu on 2/20/24.
//

import Foundation

struct Expense {
    var id = UUID()
    var expenseName: String
    var cost: String
    var date: Date
    var category: String
}

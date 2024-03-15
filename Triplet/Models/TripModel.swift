//
//  TripModel.swift
//  Triplet
//
//  Created by Derek Ma on 2/20/24.
//

import Foundation
import FirebaseFirestore


struct Trip: Identifiable, Codable {
    @DocumentID var id: String?
    var owner: String
    var name: String
    var start: Date?
    var end: Date?
    var destination: GeoPoint
    var numGuests: Int?
    var notes: [Note]?
    var events: [Event]?
    var expenses: [Expense]?
    var city: String
    var state: String
}

struct Note: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String = "Untitled Note"
    var content: String = ""
}

enum EventType: String, Codable, CaseIterable{
    case housing = "House"
    case food = "Food"
    case attraction = "Attraction"
    case transit = "Transit"
}

enum FoodCategory: String, Codable, CaseIterable {
    case breakfast = "Breakfast/Brunch"
    case lunch = "Lunch"
    case dinner = "Dinner"
}

struct Event: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var location: GeoPoint
    var type: EventType
    var category: FoodCategory?
    var start: Date
    var address: String
    var end: Date
}

enum ExpenseCategory: String, Codable, CaseIterable {
    case housing = "Housing"
    case activities = "Activities"
    case entertainment = "Entertainment"
    case transportation = "Transportation"
    case food = "Food"
    case other = "Other"
}

struct Expense: Identifiable, Codable, Equatable {
    var id: String?
    var name: String
    var date: Date
    var category: ExpenseCategory
    var cost: Double
    
    // Implement Equatable conformance
    static func == (lhs: Expense, rhs: Expense) -> Bool {
        return lhs.id == rhs.id
    }
}

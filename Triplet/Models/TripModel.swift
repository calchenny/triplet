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
    var notes: [Note]
    var events: [Event]
    var expenses: [Expense]
}

struct Note: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String = "Untitled Note"
    var content: String = ""
}

enum EventType: String, Codable {
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
    var end: Date
}

struct Expense: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var date: Date
    var category: String
    var cost: Double
}

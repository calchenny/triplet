//
//  TripModel.swift
//  Triplet
//
//  Created by Derek Ma on 2/20/24.
//
import Foundation
import FirebaseFirestore

struct Trip: Identifiable, Decodable {
    let id: String
    let name: String
    let start: Date
    let end: Date
    let destination: GeoPoint
    let numGuests: Int?
}

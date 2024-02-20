//
//  TripModel.swift
//  Triplet
//
//  Created by Derek Ma on 2/20/24.
//

import FirebaseFirestore

struct Trip: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var start: Date
    var end: Date
    var destination: GeoPoint
    var numGuests: Int?
}

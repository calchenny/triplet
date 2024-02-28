//
//  DestinationViewModel.swift
//  Triplet
//
//  Created by Calvin Chen on 2/27/24.
//

import Foundation

class DestinationViewModel: ObservableObject {
    @Published var city: String?
    @Published var state: String?
    @Published var country: String?
    @Published var latitude: Double?
    @Published var longitude: Double?
        
    // Loading the data onto model property
    func setDestination(city: String?, state: String?, country: String?, latitude: Double?, longitude: Double?) async {
        DispatchQueue.main.async {
            self.city = city
            self.state = state
            self.country = country
            self.latitude = latitude
            self.longitude = longitude
        }
    }
}

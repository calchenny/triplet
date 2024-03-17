//
//  LandmarkModel.swift
//  Triplet
//
//  Created by Andy Lam on 2/28/24.
//

import Foundation
import MapKit

struct Landmark: Identifiable, Hashable {
    let id: UUID = UUID()
    let placemark: MKPlacemark

    var name: String {
        self.placemark.name ?? ""
    }
    
    var address: String {
        self.placemark.title ?? ""
    }
    
    var coordinate: CLLocationCoordinate2D {
        self.placemark.coordinate
    }
}

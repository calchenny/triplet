//
//  LandmarkModel.swift
//  Triplet
//
//  Created by Andy Lam on 2/28/24.
//

import Foundation
import MapKit

struct LandmarkViewModel: Identifiable, Hashable{
    let placemark: MKPlacemark
    var id: UUID {
        return UUID()
    }
    
    var name: String {
        self.placemark.name ?? ""
    }
    
    var title: String {
        self.placemark.title ?? ""
    }
    
    var coordinate: CLLocationCoordinate2D {
        self.placemark.coordinate
    }
}

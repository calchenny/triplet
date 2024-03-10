//
//  ExpensesViewModel.swift
//  Triplet
//
//  Created by Newland Luu on 3/9/24.
//

import SwiftUI
import EventKit
import ScalingHeaderScrollView
import MapKit
import FirebaseFirestore

class ExpensesViewModel: ObservableObject {
    var tripId: String = "Placeholder tripId"
    @Published var expenses: [Expense] = []

    @Published var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 47.608013, longitude: -122.335167), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))

    @Published var collapseProgress: CGFloat = 0

    let minHeight: CGFloat = 100.0
    let maxHeight: CGFloat = 250.0

}

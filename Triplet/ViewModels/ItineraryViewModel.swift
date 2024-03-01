//
//  ItineraryModel.swift
//  Triplet
//
//  Created by Andy Lam on 2/28/24.
//

import SwiftUI
import EventKit
import ScalingHeaderScrollView
import MapKit

struct Event: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let date: Date
    let time: Date
    let category: String
}

class ItineraryViewModel: ObservableObject {
    @Published var events: [Event] = []
    
    @Published var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 47.608013, longitude: -122.335167), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
    
    @Published var collapseProgress: CGFloat = 0
    
    let minHeight: CGFloat = 100.0
    let maxHeight: CGFloat = 250.0
    
    var sortedEvents: [Event] {
        return events.sorted { (event1, event2) -> Bool in
            // Compare dates and times for sorting
            if event1.date != event2.date {
                return event1.date < event2.date
            } else {
                return event1.time < event2.time
            }
        }
    }

    func addEvent(name: String, location: String, date: Date, time: Date, category: String) {
        let newEvent = Event(name: name, location: location, date: date, time: time, category: category)
        print(formatDate(newEvent.date))
        events.append(newEvent)
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd" // Customize the format as needed
        return dateFormatter.string(from: date)
    }

    func deleteEvent(at index: Int) {
        events.remove(at: index)
    }
}

//
//  ItineraryModel.swift
//  Triplet
//
//  Created by Andy Lam on 2/28/24.
//

import SwiftUI
import EventKit

struct Event: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let date: Date
    let time: Date
    let category: String?
}

class ItineraryModel: ObservableObject {
    @Published var events: [Event] = []
    
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
        events.append(newEvent)
    }

    func deleteEvent(at index: Int) {
        events.remove(at: index)
    }
}

//
//  ActiveTripViewModel.swift
//  Triplet
//
//  Created by Andy Lam on 3/18/24.
//

import SwiftUI
import EventKit
import ScalingHeaderScrollView
import FirebaseFirestore

class ActiveTripViewModel: ObservableObject {
    @Published var checkedEventIDs: Set<String> = []
    
    // check if event is in list
    func isEventChecked(eventID: String) -> Bool {
        return checkedEventIDs.contains(eventID)
    }

    func toggleEventCheck(eventID: String) {
        if checkedEventIDs.contains(eventID) {
            checkedEventIDs.remove(eventID)
        } else {
            checkedEventIDs.insert(eventID)
        }
    }
    
}

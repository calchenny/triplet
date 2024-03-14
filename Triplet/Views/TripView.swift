//
//  TripView.swift
//  Triplet
//
//  Created by Derek Ma on 3/13/24.
//

import SwiftUI

struct TripView: View {
    var tripId: String
    @Binding var isActive:Bool
    var body: some View {
        TabView {
            if isActive {
                NavigationStack {
                    DayOfView()
                }
                .tabItem {
                    Image(systemName: "star.fill")
                }
            }
            
            NavigationStack {
                OverviewView(tripId: tripId)
            }
            .tabItem {
                Image(systemName: "text.book.closed")
            }
            NavigationStack {
                ItineraryView(tripId: tripId)
            }
            .tabItem {
                Image(systemName: "calendar")
            }
            NavigationStack {
                ExpensesView()
            }
            .tabItem {
                Image(systemName: "dollarsign.circle")
            }
        }
        .tint(Color("Dark Blue"))
    }
}

//#Preview {
//    TripView(tripId: "bXQdm19F9v2DbjS4VPyi", isActive: 0)
//}

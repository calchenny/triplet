//
//  TripView.swift
//  Triplet
//
//  Created by Derek Ma on 3/13/24.
//

import SwiftUI
import AnimatedTabBar

struct TripView: View {
    var tripId: String
    @Binding var isActive:Bool
    @State var selectedIndex: Int = 0
    let names = ["star", "text.book.closed", "list.clipboard", "dollarsign.square"]
    func wiggleButtonAt(_ index: Int, name: String) -> some View {
        WiggleButton(image: Image(systemName: name), maskImage: Image(systemName: "\(name).fill"), isSelected: index == selectedIndex)
            .scaleEffect(1.2)
    }
    
    var body: some View {
        if selectedIndex == 0 {
            NavigationStack {
                DayOfView()
            }
        } else if selectedIndex == 3 {
            NavigationStack {
                ExpensesView(tripId: tripId)
            }
        } else if selectedIndex == 2 {
            NavigationStack {
                ItineraryView(tripId: tripId)
            }
        } else {
            NavigationStack {
                OverviewView(tripId: tripId)
            }
        }
        Spacer()
        // If trip is active, display all buttons
        if isActive {
            AnimatedTabBar(selectedIndex: $selectedIndex,
                                           views: (0..<names.count).map { wiggleButtonAt($0, name: names[$0]) })
                .cornerRadius(16)
                .selectedColor(.darkTeal)
                .unselectedColor(.darkTeal.opacity(0.6))
                .ballColor(.darkTeal)
                .verticalPadding(15)
                .ballTrajectory(.teleport)
        } else {
            AnimatedTabBar(selectedIndex: $selectedIndex,
                                           views: (1..<names.count).map { wiggleButtonAt($0, name: names[$0]) })
                .cornerRadius(16)
                .selectedColor(.darkTeal)
                .unselectedColor(.darkTeal.opacity(0.6))
                .ballColor(.darkTeal)
                .verticalPadding(15)
                .ballTrajectory(.teleport)
        }
    }
}

#Preview {
    TripView(tripId: "bXQdm19F9v2DbjS4VPyi", isActive: .constant(false))
}

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
    @StateObject var tripViewModel: TripViewModel = TripViewModel()
    @Binding var isActive: Bool
    @State var selectedIndex: Int = 0

    func wiggleButtonAt(_ index: Int, name: String) -> some View {
        WiggleButton(image: Image(systemName: name), maskImage: Image(systemName: "\(name).fill"), isSelected: index == selectedIndex)
            .scaleEffect(1.2)
    }
    
    func getViews(isActive: Bool) -> [some View] {
        let active = ["star", "text.book.closed", "list.clipboard", "dollarsign.square"]
        let inActive = ["text.book.closed", "list.clipboard", "dollarsign.square"]
        
        return isActive ? (0..<active.count).map { wiggleButtonAt($0, name: active[$0]) } 
        : (0..<inActive.count).map { wiggleButtonAt($0, name: inActive[$0]) }
    }
    
    var body: some View {
        VStack {
                switch selectedIndex {
                case 0:
                    NavigationStack {
                        if isActive {
                            DayOfView(tripId: tripId)
                        } else {
                            OverviewView(tripId: tripId)
                        }
                    }
                case 1:
                    NavigationStack {
                        if isActive {
                            OverviewView(tripId: tripId)
                        } else {
                            ItineraryView(tripId: tripId)
                        }
                    }
                case 2:
                    NavigationStack {
                        if isActive {
                            ItineraryView(tripId: tripId)
                        } else {
                            ExpensesView(tripId: tripId)
                        }
                    }
                default:
                    NavigationStack {
                        ExpensesView(tripId: tripId)
                    }
                }
                AnimatedTabBar(selectedIndex: $selectedIndex, views: getViews(isActive: isActive))
                    .cornerRadius(16)
                    .selectedColor(.darkTeal)
                    .unselectedColor(.darkTeal.opacity(0.6))
                    .ballColor(.darkTeal)
                    .verticalPadding(15)
                    .ballTrajectory(.teleport)
        }
        .environmentObject(tripViewModel)
        .onAppear {
            tripViewModel.subscribe(tripId: tripId)
        }
        .onDisappear {
            tripViewModel.unsubscribe()
        }
    }
}

#Preview {
    TripView(tripId: "9xXh1qW2Yh9dRT5qYT0m", isActive: .constant(false))
}

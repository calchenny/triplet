//
//  HomeView.swift
//  Triplet
//
//  Created by Xiaolin Ma on 2/22/24.
//

import SwiftUI
import AnimatedTabBar


struct HomeView: View {
    @State var selectedIndex: Int = 0
    let names = ["house", "plus.app", "gearshape"]

    func wiggleButtonAt(_ index: Int, name: String) -> some View {
        WiggleButton(image: Image(systemName: name), maskImage: Image(systemName: "\(name).fill"), isSelected: index == selectedIndex)
            .scaleEffect(1.2)
    }
    
    var body: some View {
        if selectedIndex == 2 {
            SettingView()
        } else if selectedIndex == 1 {
            NewTripView()
        } else {
            MyTripsView()
        }
        Spacer()
        AnimatedTabBar(selectedIndex: $selectedIndex, views: (0..<names.count).map { wiggleButtonAt($0, name: names[$0]) })
            .cornerRadius(16)
            .selectedColor(.darkTeal)
            .unselectedColor(.darkTeal.opacity(0.6))
            .ballColor(.darkTeal)
            .verticalPadding(20)
            .ballTrajectory(.teleport)
    }
}

//#Preview {
//    HomeView()
//}

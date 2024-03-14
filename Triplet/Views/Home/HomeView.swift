//
//  HomeView.swift
//  Triplet
//
//  Created by Xiaolin Ma on 2/22/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userModel: UserModel
    @EnvironmentObject var loginViewModel: LoginViewModel
    var body: some View {
        TabView {
            NavigationStack {
                MyTripsView()
            }
                .tabItem {
                Label("Menu", systemImage: "list.dash")
                }
            NavigationStack {
                NewTripView()
            }
                .tabItem {
                    Label("New Trip", systemImage: "square.and.pencil")
                }
            NavigationStack {
                SettingView()
            }
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    HomeView()
}

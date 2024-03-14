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
                Image(systemName: "house.fill")
            }
            NavigationStack {
                NewTripView()
            }
            .tabItem {
                Image(systemName: "square.and.pencil")
            }
            NavigationStack {
                SettingView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
            }
        }
        .tint(Color("Dark Blue"))

    }
}

#Preview {
    HomeView()
}

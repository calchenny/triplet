//
//  RootView.swift
//  Triplet
//
//  Created by Andy Lam on 2/18/24.
//

import SwiftUI

struct RootView: View {
    @StateObject var userModel = LoginViewModel()
    
    // still need to work on signed-in user logging back on
    var body: some View {
        // will probably need a switch statement here
        NavigationStack {
            HomeView()
        }
        .environmentObject(userModel)
    }
}


#Preview {
    RootView()
}

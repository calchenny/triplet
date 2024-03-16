//
//  RootView.swift
//  Triplet
//
//  Created by Andy Lam on 2/18/24.
//

import SwiftUI
import Firebase

struct RootView: View {
    @StateObject var loginViewModel: LoginViewModel = LoginViewModel()
    @StateObject var authenticationModel: AuthenticationModel = AuthenticationModel()
    
    var body: some View {
        NavigationStack {
            if Auth.auth().currentUser != nil {
                HomeView()
            } else {
                LoginView()
            }
        }
        .environmentObject(loginViewModel)
        .environmentObject(authenticationModel)
    }
}


#Preview {
    RootView()
}

//
//  RootView.swift
//  Triplet
//
//  Created by Andy Lam on 2/18/24.
//

import SwiftUI

struct RootView: View {
    @StateObject var loginViewModel = LoginViewModel()
    
    var body: some View {
        // will probably need a switch statement here
        NavigationStack {
            LoginView()
        }
        .tint(Color("Dark Blue"))
        .preferredColorScheme(.light)
        .environmentObject(loginViewModel)
    }
    
//    @StateObject var userViewModel = UserModel()
//    @State var loggedIn: Bool = false
//    func isLoggedIn() {
//        if let _ = UserDefaults.standard.string(forKey: "UserAuthToken") {
//            loggedIn = true
//            print("loggedIn")
//        } else {
//            loggedIn = false
//            print("logged out")
//        }
//        
//    }
//    // still need to work on signed-in user logging back on
//    var body: some View {
//        switch (loginViewModel.authToken) {
//            
//        case (.none):
//            NavigationStack {
//                LoginView()
//            }
//            .tint(Color("Dark Blue"))
//            .preferredColorScheme(.light)
//            .environmentObject(loginViewModel)
//            .onAppear {
//                isLoggedIn()
//            }
//        
//        
//        case (.some(let authToken)):
//            NavigationStack {
//                HomeView()
//            }
//            .environmentObject(userViewModel)
//        }
//    }
}


#Preview {
    RootView()
}

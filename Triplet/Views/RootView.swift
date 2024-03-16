//
//  RootView.swift
//  Triplet
//
//  Created by Andy Lam on 2/18/24.
//

import SwiftUI

struct RootView: View {
    @StateObject var loginViewModel: LoginViewModel = LoginViewModel()
    @StateObject var userModel: UserModel = UserModel()
    var body: some View {
        Group {
            if loginViewModel.userSession != nil {
                NavigationStack {
                    LoadingView()
                }
            } else {
                NavigationStack {
                    LoginView()
                }
            }
        }
        .environmentObject(userModel)
        .environmentObject(loginViewModel)
        //for newland to test
        //testAPICallsView()
    }
}


#Preview {
    RootView()
}

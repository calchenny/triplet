//
//  RootView.swift
//  Triplet
//
//  Created by Andy Lam on 2/18/24.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @EnvironmentObject var userModel: UserModel
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
        //for newland to test
        //testAPICallsView()
    }
}


#Preview {
    RootView()
}

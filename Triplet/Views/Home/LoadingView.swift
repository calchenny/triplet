//
//  LoadingView.swift
//  Triplet
//
//  Created by Xiaolin Ma on 3/8/24.
//

import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var isUserLoaded = false
    @EnvironmentObject var userModel: UserModel
    var body: some View {
        ZStack {
            VStack {
                Image(.fullIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.6, alignment: .center)
                    .padding(.bottom)
                ProgressView()
                    .controlSize(.large)
                    .progressViewStyle(.circular)
                    .padding(.top)
            }
        }
        .task {
            do {
                print("Loading user data")
                try await userModel.setUid(uid: loginViewModel.fetchUserUID())
                // Once user data is loaded, navigate to the home view
                self.isUserLoaded = true
            } catch {
                print("No user data found")
            }
        }
        .navigationDestination(isPresented: $isUserLoaded) {
            HomeView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    NavigationStack {
        LoadingView()
            .environmentObject(LoginViewModel())
            .environmentObject(UserModel())
    }
}

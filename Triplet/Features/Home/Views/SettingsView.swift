
//
//  SettingView.swift
//  Triplet
//
//  Created by Xiaolin Ma on 2/22/24.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var authenticationModel: AuthenticationModel
    @State var signedOut = false
    @State var notifications = false
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.custom("Poppins-Bold", size: 30))
                .foregroundStyle(.darkTeal)
                .padding()
            Form {
                Section(header: Text("Account Settings")) {
                    Toggle("Push Notifications", isOn: $notifications)
                        .font(.custom("Poppins-Regular", size: 15))
                    Text("About Us")
                        .font(.custom("Poppins-Regular", size: 15))
                    
                }
                HStack {
                    Button {
                        authenticationModel.signOut {
                            signedOut = true
                        }
                    } label: {
                        Text("Logout")
                            .font(.custom("Poppins-Medium", size: 18))
                            .padding(.vertical, 20)
                            .padding(.horizontal, 30)
                            .foregroundStyle(.white)
                            .frame(width: 200, height: 50)
                            .background(.darkTeal)
                            .cornerRadius(15)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .navigationDestination(isPresented: $signedOut) {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            }
            .scrollDisabled(true)
            .background(Color.white)
            .cornerRadius(10)
            .scrollContentBackground(.hidden)
        }
    }
}

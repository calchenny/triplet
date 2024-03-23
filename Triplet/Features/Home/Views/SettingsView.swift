
//
//  SettingView.swift
//  Triplet
//
//  Created by Xiaolin Ma on 2/22/24.
//

import SwiftUI
import PopupView

struct SettingView: View {
    @EnvironmentObject var authenticationModel: AuthenticationModel
    @State var signedOut = false
    @State var showAboutUsToggle = false
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.custom("Poppins-Bold", size: 30))
                .foregroundStyle(.darkTeal)
                .padding()
            Form {
                    Button {
                        showAboutUsToggle = true
                    } label: {
                        Text("About Us")
                            .font(.custom("Poppins-Regular", size: 15))
                            .foregroundColor(.black)
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
        .popup(isPresented: $showAboutUsToggle) {
            AboutUs(showAboutUs: $showAboutUsToggle)
        } customize: { popup in
            popup
                .type(.floater())
                .position(.center)
                .animation(.spring())
                .closeOnTap(false)
                .closeOnTapOutside(false)
                .isOpaque(true)
                .backgroundColor(.black.opacity(0.25))
        }
        .padding()
    }
}


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
    var body: some View {
        VStack {
            Spacer()
            VStack{
                Text("Settings")
                    .font(.custom("Poppins-Bold", size: 30))
                    .foregroundStyle(.darkTeal)
            }
            .padding()
            ZStack {
                Form {
                    Section(header: Text("Account Settings")) {
                        Toggle("Push Notifications", isOn: .constant(false))
                            .font(.custom("Poppins-Regular", size: 15))
                        Text("About Us")
                            .font(.custom("Poppins-Regular", size: 15))
                        Text("Privacy Policy")
                            .font(.custom("Poppins-Regular", size: 15))
                        Text("Terms and conditions")
                            .font(.custom("Poppins-Regular", size: 15))
                        
                    }
                    Button {
                        authenticationModel.signOut {
                            signedOut = true
                        }
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.darkTeal)
                            Text("Logout")
                                .font(.custom("Poppins-Regular", size: 18))
                                .foregroundColor(.white)
                                .padding(.vertical, 7)
                        }
                        
                    }
                    
                }
                .navigationDestination(isPresented: $signedOut) {
                    LoginView()
                        .navigationBarBackButtonHidden(true)
                }
                .scrollDisabled(true)
                .background(Color.white)
                .cornerRadius(10)
                .padding(30)
                .scrollContentBackground(.hidden)
            }
            
        }
    }
}

#Preview {
    SettingView()
}

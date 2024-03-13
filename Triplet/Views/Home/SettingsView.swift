
//
//  SettingView.swift
//  Triplet
//
//  Created by Xiaolin Ma on 2/22/24.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @EnvironmentObject var userModel: UserModel
    @State var signedOut = false
    var body: some View {
        VStack {
            Spacer()
            VStack{
                Text("Setting")
                    .font(.custom("Poppins-Regular", size: 18))
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
                    Button{
                        Task {
                            await loginViewModel.signOut()
                            userModel.unsubscribe()
                            signedOut = true
                        }
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.darkBlue)
                            Text("Logout")
                                .font(.custom("Poppins-Regular", size: 18))
                                .foregroundColor(.white)
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

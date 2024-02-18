//
//  Login.swift
//  Triplet
//
//  Created by Andy Lam on 2/18/24.
//

import SwiftUI


struct Login: View {
    @StateObject var login = LoginViewModel()
    var body: some View {
        ZStack {
            VStack{
                VStack {
                    Text("Get Started with Phone Number")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.black)
                        .padding()
                    
                    // add our logo image here
                    Image("")
                        .resizable()
                        .aspectRatio(contentMode:.fit)
                        .padding()
                    
                    Text("You'll receive a code\n to verify.")
                        .font(.title2)
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Enter Your Number")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                            Text("+1 \(login.phoneNumber)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.black)
                        }
                        Spacer(minLength: 0)
                        
                        
                        NavigationLink(destination: VerificationView(login: login), isActive: $login.goToVerify){
                            Text("")
                                .hidden()
                        }
                        
                        // Call function from usermodel to send code
                        Button(action: login.sendCode, label: {
                            Text("Continue")
                                .foregroundStyle(Color.black)
                                .padding(.vertical, 18)
                                .padding(.horizontal, 38)
                                .background(Color.gray)
                                .cornerRadius(15)
                        })
                        .disabled(login.phoneNumber == "" ? true : false)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
                
                }
                .frame(height: UIScreen.main.bounds.height / 1.8)
                .background(Color.white)
                .cornerRadius(20)
                
                CustomNumPad(value: $login.phoneNumber, isVerify: false)
                
            }
            .background(Color.white.ignoresSafeArea(.all, edges: .bottom))
            
            if login.error {
                AlertView(msg: login.errorMsg, show: $login.error)
            }
        }
    }

}

#Preview {
    Login()
}

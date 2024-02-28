//
//  Login.swift
//  Triplet
//
//  Created by Andy Lam on 2/18/24.
//

import SwiftUI


struct Login: View {
    @EnvironmentObject var login: LoginViewModel
    @State var navigateToVerify: Bool = false
    
    
    // function to send code to phone
    func continueClick() {
        Task {
            do {
                let _ = try await login.sendCode()
                navigateToVerify = true
                print("Successfully sent code")
            }catch {
                navigateToVerify = false
                print("Some error when sending code")
            }
        }
        print("nextclick done")
    }
    
    var body: some View {
        ZStack {
            VStack{
                VStack {
                    Text("Get Started with Phone Number")
                        .font(.custom("Poppins-Regular", size: 32))
                        .fontWeight(.thin)
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundStyle(Color.black)
//                        .padding()
                    
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
                    
                    
                    //Handles the phone number text view; could maybe do a state variable here instead for the
                    // phone number
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
                        .frame(maxWidth: .infinity)
                        Spacer(minLength: 0)
                        
                        
                        // Call function from usermodel to send code
                        Button{
                            continueClick()
                        }label: {
                            Text("Continue")
                                .foregroundStyle(Color.black)
                                .padding(.vertical, 18)
                                .padding(.horizontal, 28)
                                .background(Color.gray)
                                .cornerRadius(15)
                        }
                        .disabled(login.phoneNumber == "" ? true : false)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
                
                }
                
                // track when to send to verificationview
                .navigationDestination(isPresented: $navigateToVerify) {
                    VerificationView()
                }
                .frame(height: UIScreen.main.bounds.height / 1.8)
                .background(Color.white)
                .cornerRadius(20)
                
                // custom number pad
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
        .environmentObject(LoginViewModel())
}

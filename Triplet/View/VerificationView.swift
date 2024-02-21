//
//  VerificationView.swift
//  Triplet
//
//  Created by Andy Lam on 2/18/24.
//

import SwiftUI

struct VerificationView: View {
    @EnvironmentObject var login : LoginViewModel
    @Environment(\.presentationMode) var present
    @State var navigateToHome: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                VStack{
                    HStack {
                        Button(action: {present.wrappedValue.dismiss()}) {
                            Image(systemName: "arrow.left")
                                .font(.title2)
                                .foregroundStyle(Color.black)
                        }
                        
                        Spacer()
                        
                        Text("Verify Phone")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.black)
                        
                        Spacer()
                    }
                    .padding()
                    
                    Text("Code sent to \(login.phoneNumber)")
                        .foregroundStyle(Color.gray)
                        .padding(.bottom)
                    Spacer(minLength: 0)
                    
                    HStack(spacing: 15) {
                        ForEach(0..<6, id: \.self){index in
                            CodeView(code: getCodeAtIndex(index: index))
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 0)
                    
                    HStack(spacing: 6) {
                        Text("Didn't receive code?")
                            .foregroundStyle(Color.gray)
                        
                        Button {
                            resendCode()
                        }label: {
                            Text("Request Again")
                                .fontWeight(.bold)
                                .foregroundStyle(Color.black)
                        }
                    }
                    
                    Button{
                        verifyAndCreateAccount()
                    } label: {
                        Text("Verify and Create Account")
                            .foregroundStyle(Color.black)
                            .padding(.vertical)
                            .frame(width:UIScreen.main.bounds.width - 30)
                            .background(Color.gray)
                            .cornerRadius(15)
                    }
                }
                .navigationDestination(isPresented: $navigateToHome) {
                    ContentView()
                        .navigationBarBackButtonHidden(true)
                }
                .frame(height: UIScreen.main.bounds.height / 1.8)
                .background(Color.white)
                .cornerRadius(20)
                
                CustomNumPad(value: $login.code, isVerify: true)
            }
            .background(Color("bg").ignoresSafeArea(.all, edges: .bottom))
            
            if login.error{
                AlertView(msg: login.errorMsg, show: $login.error)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    
    //function to resend code
    func resendCode() {
            Task {
                do {
                    try await login.requestCode()
                }catch {
                    print("An unexpected error occurred: \(error)")
                }
            }
    }

    // function that verifies otp code and then creates the account (same process)
    func verifyAndCreateAccount() {
        Task {
            do {
                try await login.verifyCode()
                navigateToHome = true
                
            } catch {
                navigateToHome = false
                print("An unexpected error occurred: \(error)")
            }
        }
    }
    
    // this function handles code view
    func getCodeAtIndex(index: Int) -> String {
        if login.code.count > index {
            let start = login.code.startIndex
            
            let current = login.code.index(start, offsetBy: index)
            
            return String(login.code[current])
        }
        return ""
    }
}

struct CodeView: View {
    var code: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(code)
                .foregroundStyle(Color.black)
                .fontWeight(.bold)
                .font(.title2)
                .frame(height:45)
            
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(height:4)
        }
    }
}
#Preview {
    VerificationView()
}

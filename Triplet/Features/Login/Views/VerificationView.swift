//
//  VerificationView.swift
//  Triplet
//
//  Created by Andy Lam on 2/18/24.
//

import SwiftUI

struct VerificationView: View {
    @EnvironmentObject var loginViewModel : LoginViewModel
    @EnvironmentObject var authenticationModel: AuthenticationModel
    @Environment(\.presentationMode) var present
    @State var navigateToHome: Bool = false
    @FocusState var isFocused: Bool

    func otpDigit(at index: Int) -> String {
        guard index < loginViewModel.code.count else {
            return ""
        }
        let digitIndex = loginViewModel.code.index(loginViewModel.code.startIndex, offsetBy: index)
        return String(loginViewModel.code[digitIndex])
    }
    
    func handleChange() {
        if loginViewModel.code.count == 6 {
            verifyAndCreateAccount()
        } else {
            loginViewModel.code = String(loginViewModel.code.prefix(6))
        }
    }

    //function to resend code
    func resendCode() {
        authenticationModel.verifyPhoneNumber(loginViewModel.phoneNumber)
    }

    // function that verifies otp code and then creates the account (same process)
    func verifyAndCreateAccount() {
        authenticationModel.signIn(loginViewModel.code) {
            navigateToHome.toggle()
            loginViewModel.code = ""
            loginViewModel.phoneNumber = ""
        }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Text("Verify Phone Number")
                        .font(.custom("Poppins-Bold", size: 30))
                        .fontWeight(.bold)
                        .foregroundStyle(.darkTeal)
                    
                    Spacer()
                    
                    if loginViewModel.loading{
                        ProgressView()
                    }
                }
                .padding()
                
                Text("Enter in the 6-digit OTP we just sent to \(loginViewModel.phoneNumber)")
                    .font(.custom("Poppins-Regular", size: 14))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 250)
                    .padding(.bottom)
                
                TextField("", text: $loginViewModel.code)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .frame(width: 0, height: 0)
                    .focused($isFocused)
                    .onChange(of: loginViewModel.code) {
                        handleChange()
                    }
                HStack {
                    ForEach(0..<6, id: \.self) { index in
                        Text(otpDigit(at: index))
                            .frame(width: 50, height: 50)
                            .contentShape(Rectangle())
                            .multilineTextAlignment(.center)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(loginViewModel.code == "" || loginViewModel.code.count - 1 < index ? .darkerGray : .green, lineWidth: 1)
                            )
                    }
                }
                .onTapGesture {
                    isFocused = true
                }
                Button{
                    resendCode()
                } label: {
                    Text("Resend Code")
                        .font(.custom("Poppins-Medium", size: 18))
                        .foregroundStyle(.white)
                        .padding(.vertical)
                        .frame(width: 200, height: 50)
                        .background(.darkTeal)
                        .cornerRadius(15)
                }
                .padding(.top, 20)
                Spacer()
            }
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()
                    .navigationBarBackButtonHidden(true)
            }
            .background(Color.white)
            .cornerRadius(20)
                            
            if loginViewModel.error {
                AlertView(msg: loginViewModel.errorMsg, show: $loginViewModel.error)
            }
            Button {
                present.wrappedValue.dismiss()
                loginViewModel.code = ""
            } label: {
                Image(systemName: "arrowshape.backward.fill")
                    .font(.title2)
                    .padding()
                    .background(.darkTeal)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .padding(.top, 60)
            .padding(.leading)
            .tint(.primary)
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = false
        }
    }
}

#Preview {
    VerificationView()
        .environmentObject(LoginViewModel())
}

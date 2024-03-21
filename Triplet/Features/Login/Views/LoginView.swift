//
//  Login.swift
//  Triplet
//
//  Created by Andy Lam on 2/18/24.
//

import SwiftUI
import PhoneNumberKit

struct LoginView: View {
    @EnvironmentObject var login: LoginViewModel
    @EnvironmentObject var authenticationModel: AuthenticationModel
    @State var navigateToVerify: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    private let partialFormatter = PartialFormatter(
        phoneNumberKit: PhoneNumberKit(),
        defaultRegion: "US",
        maxDigits: 10)
    
    func continueClick() {
        authenticationModel.verifyPhoneNumber(login.phoneNumber) {
            navigateToVerify.toggle()
        }
    }
    
    var body: some View {
        ZStack {
            VStack{
                // Logo
                Image(.fullIcon)
                    .resizable()
                    .scaledToFit()
                    .padding(.vertical, 100)
                    .frame(width: UIScreen.main.bounds.width * 0.5, alignment: .center)
                    
                // Handles the phone number text view
                HStack {
                    HStack {
                        Text("🇺🇸 +1") // Hardcoded country code
                            .font(.custom("Poppins-Regular", size: 16))
                        
                        TextField("(201) 555-0123", text: $login.phoneNumber)
                            .font(.custom("Poppins-Regular", size: 16))
                            .onChange(of: login.phoneNumber) {
                                // Limit the character count to 14
                                // Phone number is 14 characters long including dash & parentheses
                                if (login.phoneNumber.count > 14) {
                                    login.phoneNumber = String(login.phoneNumber.prefix(14))
                                }
                                // Formatting the phone number into the correct format
                                let partialFormattedNumber = partialFormatter.formatPartial(login.phoneNumber)
                                login.phoneNumber = partialFormattedNumber
                            }
                            .keyboardType(.numberPad)
                            .focused($isTextFieldFocused)
                            .onTapGesture {
                                isTextFieldFocused = true
                            }

                    }
                    .frame(width: UIScreen.main.bounds.width/1.4, height: UIScreen.main.bounds.height/25)
                    .padding(5)
                    .background(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                login.phoneNumber == "" ?
                                Color(.systemGray6) :
                                login.phoneNumber.count == 14 ?
                                Color.green :
                                Color.red
                                , lineWidth: 2.0)
                    )
                    .cornerRadius(10)
                    
                }
                .padding()
                .background(Color.white)
                .navigationDestination(isPresented: $navigateToVerify) {
                    VerificationView()
                        .navigationBarBackButtonHidden(true)
                }
                
                Text("Enter your phone number to receive a OTP")
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundStyle(.darkerGray)
                    .padding(.bottom, 30)
                
                Button {
                    continueClick()
                } label: {
                    Text("Login")
                        .font(.custom("Poppins-Medium", size: 18))
                        .padding(.vertical, 20)
                        .padding(.horizontal, 30)
                        .foregroundStyle(login.phoneNumber.count < 14 ? .darkerGray : .white)
                        .frame(width: 200, height: 50)
                        .background(login.phoneNumber.count < 14 ? .lighterGray : login.phoneNumber.count == 14 ? .darkTeal : Color.red.opacity(0.5))
                        .cornerRadius(15)
                }
                .disabled(login.phoneNumber.count != 14)

                Spacer()

            }

            if login.error {
                AlertView(msg: login.errorMsg, show: $login.error)
            }
        }
        .background(.white)
        .onTapGesture {
            isTextFieldFocused = false
        }
    }

}

#Preview {
    LoginView()
        .environmentObject(LoginViewModel())
}

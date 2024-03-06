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
    @State var navigateToVerify: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    private let partialFormatter = PartialFormatter(
        phoneNumberKit: PhoneNumberKit(),
        defaultRegion: "US",
        maxDigits: 10)
    
    // function to send code to phone
    func continueClick() {
        Task {
            do {
                let _ = try await login.sendCode()
                navigateToVerify = true
                print("Successfully sent code")
            } catch {
                navigateToVerify = false
                print("Error sending code or verifying")
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack{
                Image(.fullIcon)
                    .resizable()
                    .scaledToFit()
                    .padding(.vertical, 100)
                    .frame(width: UIScreen.main.bounds.width * 0.35, alignment: .center)
                    
                //Handles the phone number text view; could maybe do a state variable here instead for the
                // phone number
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
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundStyle(Color.gray)
                    .padding(.bottom, 30)
                            
                // Call function from usermodel to send code
                Button {
                    continueClick()
                } label: {
                    Text("Login")
                        .font(.custom("Poppins-Bold", size: 16))
                        .padding(.vertical, 20)
                        .padding(.horizontal, 30)
                        .foregroundStyle(.white)
                        .frame(width: 200, height: 50)
                        .background(login.phoneNumber.count < 14 ? Color.gray.opacity(0.5) : login.phoneNumber.count == 14 ? Color(.darkBlue) : Color.red.opacity(0.5))
                        .cornerRadius(15)
                }
                .disabled(login.phoneNumber.count != 14)

                Spacer()

            }
            .onTapGesture {
                isTextFieldFocused = false
            }

            if login.error {
                AlertView(msg: login.errorMsg, show: $login.error)
            }
        }
    }

}

#Preview {
    LoginView()
        .environmentObject(LoginViewModel())
}

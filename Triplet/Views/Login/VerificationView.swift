//
//  VerificationView.swift
//  Triplet
//
//  Created by Andy Lam on 2/18/24.
//

import SwiftUI

struct VerificationView: View {
    @EnvironmentObject var login : LoginViewModel
    @EnvironmentObject var userModel : UserModel
    @Environment(\.presentationMode) var present
    @State var navigateToHome: Bool = false
    @State var pinList: [String] = ["", " ", " ", " ", " ", " "]
    @FocusState private var pinFocusState: Int?

    enum FocusPin {
        case  pinOne, pinTwo, pinThree, pinFour, pinFive, pinSix
    }
    

    //function to resend code
    func resendCode() {
            Task {
                do {
                    try await login.requestCode()
                } catch {
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
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        present.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "arrowshape.backward.fill")
                            .font(.headline)
                            .padding(12)
                            .background(.darkTeal)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4, x: 0, y: 4)
                    })
                    Spacer()
                }
                .padding(.top, 60)
                .padding(.leading, 15)
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Text("Verify Phone Number")
                        .font(.custom("Poppins-Bold", size: 24))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.black)
                    
                    Spacer()
                    
                    if login.loading{ProgressView()}
                }
                .padding()
                
                Text("Enter in the 6-digit OTP we just sent to \(login.phoneNumber)")
                    .font(.custom("Poppins-Regular", size: 14))
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                
                HStack {
                    // Loop to generate the TextFields
                    ForEach($pinList.indices, id: \.self) { pin in
                        let binding = Binding<String>(
                            get: { pinList[pin] },
                            set: { pinList[pin] = $0 }
                        )
                        TextField("", text: binding)
                        .onChange(of:binding.wrappedValue) {
                            let currentBoxCode = pinList[pin].trimmingCharacters(in: .whitespaces)
                            login.code = pinList.joined(separator: "").filter { !$0.isWhitespace }
                            
                            // When the OTP is filled out, verify the code
                            if (login.code.count == 6) {
                                verifyAndCreateAccount()
                            }
                            if (currentBoxCode.count >= 1) { // When a number is inputted, focus the next field
                                if (pin == 0) {
                                    pinList[pin] = String(pinList[pin].prefix(1))
                                } else {
                                    pinList[pin] = String(pinList[pin].prefix(2))
                                }
                                pinFocusState = pin + 1
                                
                            } else {
                                if (currentBoxCode.count == 0) { // When a number is deleted, go to previous field
                                    if (!(pin == 0)) {
                                        pinList[pin] = " " // Add the buffer space back
                                    }
                                    pinFocusState = pin - 1
                                }
                            }
                        }
                        .keyboardType(.numberPad)
                        .allowsHitTesting(false) // Prevent taps for a view
                        .textContentType(.oneTimeCode) // Enables one time code autofill
                        .padding(.vertical, 10)
                        .frame(width: 50, height: 50)
                        .cornerRadius(10)
                        .focused($pinFocusState, equals: pin) // Each field has its distinct focus state
                        .multilineTextAlignment(.center)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    pinList[pin].trimmingCharacters(in: .whitespaces) == "" ?
                                    Color(.systemGray6) :
                                    pinList[pin].trimmingCharacters(in: .whitespaces).count == 1 ?
                                    Color.green :
                                    Color.red
                                    , lineWidth: 5.0)
                        )
                        .cornerRadius(10)

                    }
                }
                .padding()
                
                Button{
                    resendCode()
                } label: {
                    Text("Resend Code")
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundStyle(.white)
                        .padding(.vertical)
                        .frame(width:UIScreen.main.bounds.width * 0.6)
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
                            
            if login.error{
                AlertView(msg: login.errorMsg, show: $login.error)
            }
        }
        .onAppear() {
            pinFocusState = 0 // The first TextField is the first one to be focused
            Task {
                print("hi from verification view")
            }
        }
    }

}

#Preview {
    VerificationView()
        .environmentObject(LoginViewModel())
}

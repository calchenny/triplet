//
//  LoginViewModel.swift
//  Triplet
//
//  Created by Andy Lam on 2/18/24.
//

import Firebase
import Foundation
import SwiftUI

// some authentication error cases
enum AuthenticationError: Error {
    case invalidPhoneNumber
    case verificationFailed(String)
    case authTokenNotFound
    case signInFailed(String)
    case unknownError
}

// initialize each error with an error string
extension AuthenticationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidPhoneNumber:
            return NSLocalizedString("Invalid phone number", comment: "")
        case .verificationFailed(let message):
            return NSLocalizedString("Verification failed: \(message)", comment: "")
        case .authTokenNotFound:
            return NSLocalizedString("Authentication token not found", comment: "")
        case .signInFailed(let message):
            return NSLocalizedString("Sign-in failed: \(message)", comment: "")
        case .unknownError:
            return NSLocalizedString("An unknown error occurred", comment: "")
        }
    }
}


class LoginViewModel: ObservableObject {
    @Published var phoneNumber:String = ""
    
    @Published var code:String = ""
    
    @Published var errorMsg:String = ""
    @Published var error:Bool = false
    
    
    @Published var authToken: String?
    
    init() {
        authToken = UserDefaults.standard.string(forKey: "authToken")
    }
    
    
    
    // function to send code to user following phone number request
    // used PhoneAuthProvider api calls
    func sendCode() async throws {
        Auth.auth().settings?.isAppVerificationDisabledForTesting = false

        let number = "+1\(phoneNumber)"
        print("My Number: \(number)")

        do {
            let verificationID = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String?, Error>) in
                PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { (verificationID, error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.errorMsg = error.localizedDescription
                            withAnimation { self.error.toggle() }
                        }
                        continuation.resume(throwing: AuthenticationError.verificationFailed(error.localizedDescription))
                    } else {
                        continuation.resume(returning: verificationID)
                    }
                }
            }

            guard let verificationID = verificationID else {
                throw AuthenticationError.unknownError
            }
            
            DispatchQueue.main.async {
                self.authToken = verificationID
            }
        } catch {
            throw error
        }
    }

    // function to verify otp code following user input of otpCode
    // used PhoneAuthProvider api calls
    func verifyCode() async throws {
        guard let authToken = self.authToken else {
            throw AuthenticationError.authTokenNotFound
        }
        
        //grab credential using authToken
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: authToken, verificationCode: code)

        // after receiving credential, set up account using the credential
        do {
            let _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                Auth.auth().signIn(with: credential) { (result, error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.errorMsg = error.localizedDescription
                            withAnimation {
                                self.error.toggle()
                            }
                        }
                        continuation.resume(throwing: AuthenticationError.signInFailed(error.localizedDescription))
                    } else {
                        print("Login Successful")
                        continuation.resume(returning: ())
                    }
                }
            }
        } catch {
            throw error
        }
    }

    func requestCode() async throws {
        do {
            try await sendCode()
            withAnimation {
                DispatchQueue.main.async {
                    self.errorMsg = "Code Sent Successfully"
                    self.error.toggle()
                }
            }
        } catch {
            throw error
        }
    }
}


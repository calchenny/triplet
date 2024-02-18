//
//  LoginViewModel.swift
//  Triplet
//
//  Created by Andy Lam on 2/18/24.
//

import Firebase
import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var phoneNumber:String = ""
    
    @Published var code:String = ""
    
    @Published var errorMsg:String = ""
    @Published var error:Bool = false
    
    @Published var CODE: String = ""
    @Published var goToVerify: Bool = false
    
    @AppStorage("log_Status") var status = false
    
    //Loading View
    
    @Published var loading = false
    
    func sendCode() {
        
        //set to false when trying on real device
        Auth.auth().settings?.isAppVerificationDisabledForTesting = false
        
        let number = "+1\(phoneNumber)"
        print("My Number: \(number)")
        
        PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                self.errorMsg = error.localizedDescription
                withAnimation { self.error.toggle() }
                return
            }
            
            // Verification ID is not nil, safely unwrap and assign
            if let verificationID = verificationID {
                self.CODE = verificationID
                self.goToVerify = true
            }
        }
    }
    
    func verifyCode() {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.CODE, verificationCode: code)
        loading = true
        Auth.auth().signIn(with: credential) { (result, err: Error?) in
            self.loading = false
            if let error = err {
                self.errorMsg = error.localizedDescription
                withAnimation {
                    self.error.toggle()
                }
                return
            }
            
            withAnimation {
                self.status = true
            }
        }
    }
    
    func requestCode() {
        sendCode()
        withAnimation {
            self.errorMsg = "Code Sent Successfully"
            self.error.toggle()
        }
    }
}


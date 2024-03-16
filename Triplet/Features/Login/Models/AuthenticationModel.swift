//
//  AuthenticationModel.swift
//  Triplet
//
//  Created by Derek Ma on 3/16/24.
//

import Firebase
import PhoneNumberKit

class AuthenticationModel: ObservableObject {
    private var verificationId: String?
    
    init() {
        verificationId = UserDefaults.standard.string(forKey: "verificationId")
    }
    
    func verifyPhoneNumber(_ phoneNumber: String, completion: (() -> Void)? = nil) {
        let e164PhoneNumber = "+1\(phoneNumber)"
        PhoneAuthProvider.provider()
          .verifyPhoneNumber(e164PhoneNumber, uiDelegate: nil) { verificationID, error in
              if let error {
                  print(error.localizedDescription)
                  return
              }
              UserDefaults.standard.set(verificationID, forKey: "verificationId")
              self.verificationId = verificationID
              completion?()
          }
    }
    
    func signIn(_ verificationCode: String, completion: (() -> Void)? = nil) {
        guard let verificationId else {
            print("Missing verificationId")
            return
        }
        let credential = PhoneAuthProvider.provider().credential(
          withVerificationID: verificationId,
          verificationCode: verificationCode
        )
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error {
                print("Hit: " + error.localizedDescription)
                return
            } else if authResult != nil {
                completion?()
            }
        }
    }
    
    func signOut(completion: (() -> Void)? = nil) {
        do {
            try Auth.auth().signOut()
            completion?()
        } catch {
            print(error.localizedDescription)
        }
    }
}

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
    @Published var phoneNumber: String = ""
    @Published var code: String = ""
    @Published var errorMsg: String = ""
    @Published var error: Bool = false
    
    //Loading View
    @Published var loading = false
}


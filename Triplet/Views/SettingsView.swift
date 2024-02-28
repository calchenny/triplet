//
//  SettingView.swift
//  Triplet
//
//  Created by Xiaolin Ma on 2/22/24.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        VStack {
            VStack{
                Image(systemName: "bicycle")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    .shadow(radius: 4)
                Text("Billy Bobby Brown")
            }
            .padding()
            VStack {
                Form {
                    Section(header: Text("Account Settings")) {
                        Text("Edit profile")
                        Text("Change password")
                        Toggle("Push Notifications", isOn: .constant(false))
                        Toggle("Dark Mode", isOn: .constant(false))
                        
                    }
                    
                    Section(header: Text("More")){
                        Text("About Us")
                        Text("Privacy Policy")
                        Text("Terms and conditions")
                    }
                    
                }
                .scrollDisabled(true)
                .background(Color.white)
                .cornerRadius(10)
                .padding(30)
                
                
            }
        }
    }
}

#Preview {
    SettingView()
}

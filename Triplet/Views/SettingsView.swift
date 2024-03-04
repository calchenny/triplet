
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
                    .overlay(Circle().stroke(Color.black, lineWidth: 1))
                Text("Billy Bobby Brown")
                    .font(.custom("Poppins-Regular", size: 18))
            }
            .padding()
            ZStack {
                Form {
                    Section(header: Text("Account Settings")) {
                        Toggle("Push Notifications", isOn: .constant(false))
                            .font(.custom("Poppins-Regular", size: 15))
                        Text("About Us")
                            .font(.custom("Poppins-Regular", size: 15))
                        Text("Privacy Policy")
                            .font(.custom("Poppins-Regular", size: 15))
                        Text("Terms and conditions")
                            .font(.custom("Poppins-Regular", size: 15))
                        
                    }
                    Button{
                        
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.darkBlue)
                            Text("Logout")
                                .font(.custom("Poppins-Regular", size: 18))
                                .foregroundColor(.white)
                        }
                        
                    }
                    
                }
                .scrollDisabled(true)
                .background(Color.white)
                .cornerRadius(10)
                .padding(30)
                .scrollContentBackground(.hidden)
            }
            
        }
    }
}

#Preview {
    SettingView()
}

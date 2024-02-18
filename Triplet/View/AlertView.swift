//
//  AlertView.swift
//  Triplet
//
//  Created by Andy Lam on 2/18/24.
//

import SwiftUI

struct AlertView: View {
    var msg: String
    @Binding var show: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15, content: {
            Text("Message")
                .fontWeight(.bold)
                .foregroundStyle(Color.gray)
            
            Text(msg)
                .foregroundStyle(Color.gray)
            
            Button(action: {
                show.toggle()
            }, label: {
                Text("Close")
                    .foregroundStyle(Color.black)
                    .padding(.vertical)
                    .frame(width: UIScreen.main.bounds.width - 100)
                    .background(Color.gray)
                    .cornerRadius(15)
            })
            .frame(alignment: .center)
        })
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal, 25)
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3).ignoresSafeArea())
    }
}

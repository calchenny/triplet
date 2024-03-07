//
//  AlertView.swift
//  Triplet
//
//  Created by Andy Lam on 2/18/24.
//

import SwiftUI


// This view handles alerts and errors and displays it to the user
struct AlertView: View {
    var msg: String
    @Binding var show: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15, content: {
            Text("Error Message")
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundStyle(.darkBlue)
            
            Text(msg)
                .font(.custom("Poppins-Regular", size: 14))
            
            Button(action: {
                show.toggle()
            }, label: {
                Text("Close")
                    .font(.custom("Poppins-Bold", size: 16))
                    .foregroundStyle(.white)
                    .padding()
                    .frame(width: UIScreen.main.bounds.width - 100)
                    .background(.darkBlue)
                    .cornerRadius(15)
            })
            .padding()
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

//
//  ExpensesView.swift
//  Triplet
//
//  Created by Newland Luu on 2/20/24.
//

import SwiftUI

struct ExpensesView: View {
    var body: some View {
        VStack {
            Text("**Most Amazing Trip**\n10/20 - 10/25")
                .padding()
                .multilineTextAlignment(.center)
                .foregroundColor(.indigo)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.indigo, lineWidth: 5)
                )
                .padding()
            Text("Expenses")
                .font(.title)
                .bold()
                .foregroundColor(.indigo)
                .padding()
            Text("$9,400.00")
                .foregroundColor(.indigo)
                .bold()
                .font(.largeTitle)
            Text("Budget: $10,000.00")
                .foregroundColor(.indigo)
            
            
        } // VStack closing bracket
        
        Spacer()
        
        VStack {
            Button() {
                
            } label: {
                Text("+ Add Expense")
                    .padding(.horizontal, 50)
                    .padding(.vertical, 15)
                    .foregroundColor(.white)
                    .background(.indigo)
                    .cornerRadius(100)
                    .bold()
                    
            }
        } // VStack closing bracket
    } // body closing bracket
} // view closing bracket

#Preview {
    ExpensesView()
}

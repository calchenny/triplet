//
//  SetBudgetView.swift
//  Triplet
//
//  Created by Newland Luu on 3/16/24.
//

import SwiftUI

struct SetBudgetView: View {
    @State private var budgetInput: String = ""
    @FocusState private var budgetFocus: Bool
    @State private var error: Bool = false
    
    var tripId: String
    @EnvironmentObject var expensesViewModel: ExpensesViewModel
    @EnvironmentObject var tripViewModel: TripViewModel
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.white)
            
            VStack (alignment: .leading) {
                HStack{
                    Button {
                        expensesViewModel.showSetBudgetPopup.toggle()
                    } label: {
                        Circle()
                            .frame(maxWidth: 30)
                            .foregroundStyle(Color("Dark Teal"))
                            .overlay {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.white)
                            }
                    }
                    HStack {
                        Text("Set a budget")
                            .font(.custom("Poppins-Bold", size: 25))
                            .foregroundStyle(Color("Dark Teal"))
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    Button {
                        if budgetInput == "" {
                            error = true
                        }
                        else {
                            if let budget = Double(budgetInput) {
                                expensesViewModel.setBudgetToFirestore(budget: budget, tripId: tripId)
                                
                                expensesViewModel.showSetBudgetPopup.toggle()
                            }
                            else {
                                print("can't convert budget to double")
                                error = true
                            }
                            
                        }
                        //expensesViewModel.showSetBudgetPopup.toggle()
                    } label: {
                        Circle()
                            .frame(maxWidth: 30)
                            .foregroundStyle(Color("Dark Teal"))
                            .overlay {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.white)
                            }
                    }
                }
                HStack {
                    Image(systemName: "dollarsign")
                        .font(.title)
                        .padding(.leading)
                        .foregroundStyle(.darkerGray)
                    
                    TextField("0.00", text: $budgetInput)
                        .padding(40)
                        .frame(maxHeight: 35)
                        .font(.custom("Poppins-Regular", size: 40))
    //                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color("Darker Gray")))
                        .keyboardType(.decimalPad)
                        .focused($budgetFocus)
                    .multilineTextAlignment(.center)
                }
                if (error == true) {
                    Text("Please enter a valid budget into the field.")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.red)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                }
                
            }
            .padding([.leading, .trailing], 20)
        }
        .padding()
        .frame(maxHeight: 200)
        .onTapGesture {
            budgetFocus = false
        }
       
    }
}

#Preview {
    SetBudgetView(tripId: "zXtPknz7e75wBCht7tZx")
}

//
//  AddNewExpenseView.swift
//  Triplet
//
//  Created by Newland Luu on 2/21/24.
//

import SwiftUI

struct AddNewExpenseView: View {
    var tripId: String
    @EnvironmentObject var expensesViewModel: ExpensesViewModel
    
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var cost: Double = 0
    @State private var costInput: String = ""
    @State private var selection: ExpenseCategory = .housing
    @State var date: Date = Date()
    @State private var error: Bool = false

    // function that will bring down the keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.white)
            
            VStack(alignment: .leading) {
                ZStack(alignment: .trailing) {
                    HStack {
                        Text("New Expense")
                            .font(.custom("Poppins-Bold", size: 30))
                            .foregroundStyle(Color("Dark Teal"))
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    Button {
                        expensesViewModel.showNewExpensePopup.toggle()
                    } label: {
                        Circle()
                            .frame(maxWidth: 30)
                            .foregroundStyle(Color("Dark Teal"))
                            .overlay {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.white)
                            }
                    }
                }
                .padding([.top, .bottom], 20)
                Text("Expense Name")
                    .font(.custom("Poppins-Medium", size: 16))
                
                TextField("Hotel, taxi, dinner, etc.", text: $name)
                    .padding(20)
                    .frame(maxHeight: 35)
                    .font(.custom("Poppins-Regular", size: 16))
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color("Darker Gray")))
                    .padding(.bottom)
                
                Text("Cost")
                    .font(.custom("Poppins-Medium", size: 16))
                
                ZStack(alignment: .leadingFirstTextBaseline) {
                    Image(systemName: "dollarsign")
                        .padding(.leading)
                        .foregroundStyle(.darkerGray)
                    
                    TextField("0.00", text: $costInput)
                        .padding(40)
                        .frame(maxHeight: 35)
                        .font(.custom("Poppins-Regular", size: 16))
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color("Darker Gray")))
                        .padding(.bottom)
                }
                
                Text("Category")
                    .font(.custom("Poppins-Medium", size: 16))
                
                Menu {
                    Picker("", selection: $selection) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            Text(category.rawValue)
                        }
                    }
                } label: {
                    HStack {
                        Text(selection.rawValue)
                            .font(.custom("Poppins-Regular", size: 16))
                            .frame(minWidth: 150)
                            .foregroundStyle(.black)
                        Image(systemName: "chevron.down")
                            .foregroundStyle(Color("Darker Gray"))
                    }
                }
                .frame(width: 200, height: 35)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color("Darker Gray")))
                .padding(.bottom)
                
                Text("Date")
                    .font(.custom("Poppins-Medium", size: 16))
                
                DatePicker("Please enter a date", selection: $date, displayedComponents: .date)
                    .labelsHidden()
                    .frame(maxHeight: 25)
                    .tint(.darkTeal)
                    .padding(.bottom)
                
                
                if (error == true) {
                    Text("Make sure all fields are filed out.")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.red)
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                }
                
                HStack {
                    Spacer()
                    Button {
                        //print("button pressed")
                        if name == "" || costInput == "" {
                            error = true
                        }
                        else {
                            print("creating new expense...")
                            if let cost = Double(costInput) {
                                expensesViewModel.addExpense(name: name, date: date, category: selection, cost: cost, tripId: tripId)
                                //expenses.append(newExpense)
                            }
                            else {
                                print("can't convert cost to double -> no expense struct created")
                            }
                            dismiss()
                        }
                        
                    } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 200, height: 40)
                            .foregroundStyle(Color("Dark Teal"))
                            .overlay(
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add expense")
                                        .font(.custom("Poppins-Medium", size: 16))
                                }
                                    .tint(.white)
                            )
                            .padding([.top, .bottom])
                    }
                    Spacer()
                }
            }
            .padding([.leading, .trailing], 20)
        }
        .padding()
        .frame(maxHeight: 600)
    }
}

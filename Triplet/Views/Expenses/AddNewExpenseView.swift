//
//  AddNewExpenseView.swift
//  Triplet
//
//  Created by Newland Luu on 2/21/24.
//

import SwiftUI

struct AddNewExpenseView: View {

    @EnvironmentObject var expensesModel: ExpensesViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var cost: Double = 0
    @State private var costInput: String = ""
    @State private var selection: String = "Select One"
    @State var date: Date = Date()
    @State private var error: Bool = false

    // function that will bring down the keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    var body: some View {

        let categories = ["Select One", "Activities", "Entertainment", "Food", "Housing", "Shopping", "Transportation", "Other"]

        VStack {
            Text("New Expense")
                .font(.custom("Poppins-Bold", size: 30))
                .foregroundColor(Color.darkTeal)
                .padding(.top, 30)

            Text("Expense Name")
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundColor(Color.darkTeal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            TextField("Hotel, Uber, Dinner, Etc.", text: $name)
                .keyboardType(.alphabet)
                .padding(8)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray)
                )
                .padding(.horizontal, 20)
            
            Text("Cost")
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundColor(Color.darkTeal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            HStack {
                Text("$")
                    .font(.custom("Poppins-Medium", size: 16))
                    .padding(.leading, 5)
                
                TextField("0.00", text: $costInput)
                    .font(.custom("Poppins-Regular", size: 16))
                    .keyboardType(.decimalPad)
                    .padding(8)
                    .cornerRadius(10)
                    .frame(width: 100)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray)
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)
            
            Text("Category")
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundColor(Color.darkTeal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            HStack {
                Picker("", selection: $selection) {
                    ForEach(categories, id: \.self) {
                        Text($0)
                            .font(.custom("Poppins-Regular", size: 16))
                    }
                }
                .frame(width: 160)
                .tint(.gray)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray)
                )
                .pickerStyle(.menu)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)

            Text("Date")
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundColor(Color.darkTeal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            HStack {
                DatePicker("",selection: $date, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .cornerRadius(10)
                .padding(.horizontal, 10)
                .background(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 10)


            if (error == true) {
                Text("Make sure all fields are filed out.")
                    .font(.custom("Poppins-Regular", size: 16))
                    .foregroundColor(.red)
                    .padding(.vertical)
            }

            Spacer()
            
            Button() {
                //print("button pressed")
                if (name == "" || costInput == "" || selection == "Select One") {
                    error = true
                }
                else {
                    print("creating new expense...")
                    if let cost = Double(costInput) {
                        expensesModel.addExpense(name: name, date: date, category: selection, cost: cost)
                        //expenses.append(newExpense)
                    }
                    else {
                        print("can't convert cost to double -> no expense struct created")
                    }
                    dismiss()
                }

            } label: {
                Text("+ Add Expense")
                    .font(.custom("Poppins-Regular", size: 15))
                    .padding(.horizontal, 50)
                    .padding(.vertical, 15)
                    .foregroundColor(.white)
                    .background(Color.darkTeal)
                    .cornerRadius(15)
                    .bold()

            }
            
            Spacer()

        } // VStack closing
    }
}

#Preview {
    AddNewExpenseView()
}

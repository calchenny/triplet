//
//  ExpensesView.swift
//  Triplet
//
//  Created by Newland Luu on 2/20/24.
//

import SwiftUI

struct ExpensesView: View {
    @State var expenses: [Expense] = []
    @State private var budget: Float = 10000.00
    @State private var currentTotal: Float = 8400.00
    @State private var percentage: Float = 0
    @State private var showNewExpenseSheet: Bool = false
    
//    func calculateTotal (total: Float) {
//        ForEach($expenses, id: \.cost) { expense in
//            if let newCost = Double(expense.cost) {
//                total = total + newCost
//            }
//
//                
//        }
//        
//    }
    
    var body: some View {
        VStack {
            Text("**Most Amazing Trip**\n10/20 - 10/25")
                .padding()
                .multilineTextAlignment(.center)
                .foregroundColor(.indigo)
                
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.indigo.opacity(0.15))
                )
                .padding()
                //.background(.indigo)
            Text("Expenses")
                .font(.title)
                .bold()
                .foregroundColor(.indigo)
                .padding()
            Text("$\(currentTotal, specifier: "%.2f")")
                .foregroundColor(.black.opacity(0.8))
                .bold()
                .font(.largeTitle)
            ProgressView(value: percentage)
                .tint(.indigo)
                .frame(minWidth: 0, maxWidth: 200)
                
            Text("Budget: $\(budget, specifier: "%.2f")")
                .foregroundColor(.indigo)
                .padding(.bottom, 15)
            
            
        } // VStack closing bracket
        .onAppear() {
            percentage = currentTotal / budget
        }
        
        VStack {

            if !expenses.isEmpty {
                
                ScrollView {
                    ForEach(expenses, id: \.expenseName) { expense in
                        
                        HStack {
                            if (expense.category == "Housing") {
                                Image(systemName: "house.fill")
                                    .font(.title3)
                                    .padding([.leading, .trailing], 10)
                            }
                            else if (expense.category == "Transportation") {
                                Image(systemName: "car.side.fill")
                                    .font(.title3)
                                    .padding([.leading, .trailing], 10)
                            }
                            else if (expense.category == "Food") {
                                Image(systemName: "fork.knife")
                                    .font(.title3)
                                    .padding([.leading, .trailing], 10)
                            }
                            else {
                                Image(systemName: "dollarsign")
                                    .font(.title3)
                                    .padding([.leading, .trailing], 10)
                            }
                            VStack {
                                    HStack{
                                        Text("\(expense.expenseName)")
                                            .bold()
                                        Spacer()
                                        Text("-$\(expense.cost)")
                                            .bold()
                                            .foregroundColor(.red)

                                    }
                                    .padding([.top, .leading, .trailing], 10)
                                    HStack {
                                        Text("\(expense.category)")
                                            .font(.caption)
                                        Spacer()
                                        Text(expense.date, format: .dateTime.day().month())
                                            .font(.caption)
                                    }
                                    .padding([.bottom, .leading, .trailing], 10)
                                    
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.15))
                        )
                    }
                }
                Spacer()
                    .onAppear {
                        //calculateTotal(total: currentTotal)
                    }
            }
            else {
                Spacer()
                Text("No expenses added yet.")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.indigo)
                Spacer()
            }
            Button() {
                print("button pressed")
                showNewExpenseSheet.toggle()
            } label: {
                Text("+ Add Expense")
                    .padding(.horizontal, 50)
                    .padding(.vertical, 15)
                    .foregroundColor(.white)
                    .background(.indigo)
                    .cornerRadius(100)
                    .bold()
                    
            }
            .sheet(isPresented: $showNewExpenseSheet) {
                AddNewExpenseView(expenses: $expenses)
            }
        } // VStack closing bracket
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
//        .overlay( /// apply a rounded border
//            RoundedRectangle(cornerRadius: 20)
//                .fill(Color.gray.opacity(0.15))
//        )

    } // body closing bracket
} // view closing bracket

#Preview {
    ExpensesView()
}

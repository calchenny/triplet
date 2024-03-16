//
//  ExpensesView.swift
//  Triplet
//
//  Created by Newland Luu on 2/20/24.
//

import SwiftUI
import EventKit
import ScalingHeaderScrollView
import MapKit
import CoreLocation
import FirebaseFirestore
import PopupView

struct ExpensesView: View {
    var tripId: String
    @StateObject var expenseViewModel = ExpensesViewModel()
    @EnvironmentObject var tripViewModel: TripViewModel
    @EnvironmentObject var userModel: UserModel
    @State private var budget: Double = 10000.00
    @State private var currentTotal: Double = 0.00
    @State private var percentage: Double = 0
    
    var body: some View {
        VStack {
            VStack {
                Text("Expenses")
                    .font(.custom("Poppins-Bold", size: 30))
                    .foregroundColor(Color.darkTeal)
                    .padding(25)
                Text("$\(expenseViewModel.currentTotal, specifier: "%.2f")")
                    .font(.custom("Poppins-Regular", size: 30))
                ProgressView(value: expenseViewModel.percentage)
                    .tint(Color.darkTeal)
                    .frame(minWidth: 0, maxWidth: 200)
                Text("Budget: $\(expenseViewModel.budget, specifier: "%.2f")")
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(Color.darkTeal)
                    .padding(.bottom, 40)
            }
            .onChange(of: expenseViewModel.expenses) {
                expenseViewModel.currentTotal = expenseViewModel.calculateTotal()
                expenseViewModel.percentage = expenseViewModel.calculatePercentage()
            }
            
            VStack {
                if !expenseViewModel.expenses.isEmpty {
                    ScrollView {
                        ForEach(expenseViewModel.expenses, id: \.name) { expense in
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .frame(height: 70)
                                    .foregroundStyle(.lighterGray)
                                HStack {
                                    if (expense.category == .housing) {
                                        HStack {
                                            Image(systemName: "building.fill")
                                                .font(.title2)
                                                .padding([.leading, .trailing], 10)
                                                .foregroundStyle(.darkTeal)
                                        }
                                        .frame(width: 50)
                                    }
                                    else if (expense.category == .activities) {
                                        HStack {
                                            Image(systemName: "figure.walk")
                                                .font(.title2)
                                                .padding([.leading, .trailing], 10)
                                                .foregroundStyle(.darkTeal)
                                        }
                                        .frame(width: 50)
                                    }
                                    else if (expense.category == .entertainment) {
                                        HStack {
                                            Image(systemName: "popcorn.fill")
                                                .font(.title2)
                                                .padding([.leading, .trailing], 10)
                                                .foregroundStyle(.darkTeal)
                                        }
                                        .frame(width: 50)
                                    }
                                    else if (expense.category == .transportation) {
                                        HStack {
                                            Image(systemName: "bus.fill")
                                                .font(.title2)
                                                .padding([.leading, .trailing], 10)
                                                .foregroundStyle(.darkTeal)
                                        }
                                        .frame(width: 50)
                                    }
                                    else if (expense.category == .food) {
                                        HStack {
                                            Image(systemName: "fork.knife")
                                                .font(.title2)
                                                .padding([.leading, .trailing], 10)
                                                .foregroundStyle(.darkTeal)
                                        }
                                        .frame(width: 50)
                                    }
                                    else {
                                        HStack {
                                            Image(systemName: "dollarsign")
                                                .font(.title2)
                                                .padding([.leading, .trailing], 10)
                                                .foregroundStyle(.darkTeal)
                                        }
                                        .frame(width: 50)
                                    }
                                    VStack {
                                        HStack{
                                            Text("\(expense.name)")
                                                .font(.custom("Poppins-Medium", size: 16))
                                            Spacer()
                                            Text("-$\(expense.cost, specifier: "%.2f")")
                                                .font(.custom("Poppins-Medium", size: 16))
                                                .foregroundColor(.red)
                                            
                                        }
                                        .padding([.top, .leading, .trailing], 10)
                                        .onAppear {
                                            
                                        }
                                        HStack {
                                            Text("\(expense.category.rawValue)")
                                                .font(.custom("Poppins-Regular", size: 12))
                                            Spacer()
                                            Text(expense.date, format: .dateTime.day().month())
                                                .font(.custom("Poppins-Regular", size: 12))
                                        }
                                        .padding([.bottom, .leading, .trailing], 10)
                                    }
                                }
                                .padding([.leading, .trailing])
                            }
                            .padding([.leading, .trailing, .bottom], 10)
                        }
                    }
                    Spacer()
                    
                }
                else {
                    Spacer()
                    Text("No expenses added yet.")
                        .font(.title3)
                        .bold()
                        .foregroundColor(Color.darkTeal)
                    Spacer()
                }
                Button {
                    expenseViewModel.showNewExpensePopup.toggle()
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 200, height: 40)
                        .foregroundStyle(Color("Dark Teal"))
                        .overlay(
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Expense")
                                    .font(.custom("Poppins-Medium", size: 16))
                            }
                                .tint(.white)
                        )
                }
                .popup(isPresented: $expenseViewModel.showNewExpensePopup) {
                    AddNewExpenseView(tripId: tripId)
                        .environmentObject(expenseViewModel)
                } customize: { popup in
                    popup
                        .type(.floater())
                        .position(.center)
                        .animation(.spring())
                        .closeOnTap(false)
                        .closeOnTapOutside(false)
                        .isOpaque(true)
                        .backgroundColor(.black.opacity(0.25))
                }
                .padding()
            } // VStack closing bracket
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            expenseViewModel.subscribe(tripId: tripId)
        }
        .onDisappear {
            expenseViewModel.unsubscribe()
        }
    } // body closing bracket
} // view closing bracket

#Preview {
    ExpensesView(tripId: "zXtPknz7e75wBCht7tZx")
}

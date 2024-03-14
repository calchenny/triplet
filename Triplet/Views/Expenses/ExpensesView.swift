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

struct ExpensesView: View {
    @State private var budget: Double = 10000.00
    @State private var currentTotal: Double = 0.00
    @State private var percentage: Double = 0
    @State private var showNewExpenseSheet: Bool = false

    @StateObject var expenseModel = ExpensesViewModel()

    func getHeaderWidth(screenWidth: CGFloat) -> CGFloat {
        let maxWidth = screenWidth * 0.9
        let minWidth = screenWidth * 0.5
        return max((1 - expenseModel.collapseProgress + 0.5 * expenseModel.collapseProgress) * maxWidth, minWidth)
    }

    func getHeaderHeight() -> CGFloat {
        let maxHeight = CGFloat(100)
        let minHeight = CGFloat(60)
        return max((1 - expenseModel.collapseProgress + 0.5 * expenseModel.collapseProgress) * maxHeight, minHeight)
    }

    func getHeaderTitleSize() -> CGFloat {
        let maxSize = CGFloat(30)
        let minSize = CGFloat(16)
        return max((1 - expenseModel.collapseProgress + 0.5 * expenseModel.collapseProgress) * maxSize, minSize)
    }

    var body: some View {
        ScalingHeaderScrollView {
            ZStack(alignment: .topLeading) {
                ZStack(alignment: .bottom) {
                    Map(position: $expenseModel.cameraPosition)
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: getHeaderWidth(screenWidth: UIScreen.main.bounds.width), height: getHeaderHeight())
                        .foregroundStyle(.evenLighterBlue)
                        .overlay(
                            VStack {
                                Text("Most Amazing Trip")
                                    .font(.custom("Poppins-Bold", size: getHeaderTitleSize()))
                                    .foregroundStyle(Color.darkTeal)
                                Text("Seattle, WA | 10/20 - 10/25")
                                    .font(.custom("Poppins-Regular", size: 13))
                                    .foregroundStyle(.darkTeal)
                            }
                        )
                        .padding(.bottom, 30)
                }
                Button {
                } label: {
                    Image(systemName: "house")
                        .font(.title2)
                        .padding()
                        .background(Color("Dark Teal"))
                        .foregroundStyle(.white)
                        .clipShape(Circle())
                }
                .padding(.top, 60)
                .padding(.leading)
                .tint(.primary)
            }
            .frame(maxWidth: .infinity)
        } content: {
            VStack {
                Text("Expenses")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color.darkTeal)
                    .padding()
                Text("$\(expenseModel.currentTotal, specifier: "%.2f")")
                    .foregroundColor(Color.darkTeal)
                    .bold()
                    .font(.largeTitle)
                ProgressView(value: expenseModel.percentage)
                    .tint(Color.darkTeal)
                    .frame(minWidth: 0, maxWidth: 200)
                
                Text("Budget: $\(expenseModel.budget, specifier: "%.2f")")
                    .foregroundColor(Color.darkTeal)
                    .padding(.bottom, 15)
            }
            .onChange(of: expenseModel.expenses) {
                expenseModel.currentTotal = expenseModel.calculateTotal()
                expenseModel.percentage = expenseModel.calculatePercentage()
                print("currentTotal: \(expenseModel.currentTotal)")
                print("percentage: \(expenseModel.percentage)")
            }
            
            VStack {
                
                if !expenseModel.expenses.isEmpty {
                    
                    ScrollView {
                        ForEach(expenseModel.expenses, id: \.name) { expense in
                            
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
                                        Text("\(expense.name)")
                                            .bold()
                                        Spacer()
                                        Text("-$\(expense.cost, specifier: "%.2f")")
                                            .bold()
                                            .foregroundColor(.red)
                                        
                                    }
                                    .padding([.top, .leading, .trailing], 10)
                                    .onAppear {
                                        
                                    }
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
                    
                }
                else {
                    Spacer()
                    Text("No expenses added yet.")
                        .font(.title3)
                        .bold()
                        .foregroundColor(Color.darkTeal)
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
                        .background(Color.darkTeal)
                        .cornerRadius(100)
                        .bold()
                }
                .sheet(isPresented: $showNewExpenseSheet) {
                    AddNewExpenseView()
                        .environmentObject(expenseModel)
                }
                .padding(30)
            } // VStack closing bracket
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
        .height(min: expenseModel.minHeight, max: expenseModel.maxHeight)
        .allowsHeaderCollapse()
        .collapseProgress($expenseModel.collapseProgress)
        .setHeaderSnapMode(.immediately)
        .ignoresSafeArea()
        .onAppear {
            expenseModel.subscribe()
        }
        .onDisappear {
            expenseModel.unsubscribe()
        }
    } // body closing bracket
} // view closing bracket

#Preview {
    ExpensesView()
}

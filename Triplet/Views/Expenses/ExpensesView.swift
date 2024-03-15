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

    init(tripId: String) {
        self.tripId = tripId
    }
    
    @State private var budget: Double = 10000.00
    @State private var currentTotal: Double = 0.00
    @State private var percentage: Double = 0
    @State var navigateToHome: Bool = false
    @EnvironmentObject var userModel: UserModel
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
                                if let trip = expenseModel.trip {
                                    Text(trip.name)
                                        .font(.custom("Poppins-Bold", size: getHeaderTitleSize()))
                                        .foregroundStyle(Color("Dark Teal"))
                                    Text("\(trip.city), \(trip.state) | \(getDateString(date: trip.start)) - \(getDateString(date: trip.end))")
                                        .font(.custom("Poppins-Medium", size: 13))
                                        .foregroundStyle(Color("Dark Teal"))
                                }
                            }
                        )
                        .padding(.bottom, 30)
                }
                Button {
                    navigateToHome = true
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
                    .font(.custom("Poppins-Bold", size: 30))
                    .foregroundColor(Color.darkTeal)
                    .padding(25)
                Text("$\(expenseModel.currentTotal, specifier: "%.2f")")
                    .font(.custom("Poppins-Regular", size: 30))
                ProgressView(value: expenseModel.percentage)
                    .tint(Color.darkTeal)
                    .frame(minWidth: 0, maxWidth: 200)
                Text("Budget: $\(expenseModel.budget, specifier: "%.2f")")
                    .font(.custom("Poppins-Medium", size: 16))
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
                    expenseModel.showNewExpensePopup.toggle()
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
                        .padding(.bottom, 30)
                }
                .popup(isPresented: $expenseModel.showNewExpensePopup) {
                    AddNewExpenseView()
                        .environmentObject(expenseModel)
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
                .padding(30)
            } // VStack closing bracket
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .navigationDestination(isPresented: $navigateToHome) {
                NavigationStack{
                    HomeView()
                }
                .navigationBarBackButtonHidden(true)
            }
        }
        .height(min: expenseModel.minHeight, max: expenseModel.maxHeight)
        .allowsHeaderCollapse()
        .collapseProgress($expenseModel.collapseProgress)
        .setHeaderSnapMode(.immediately)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            expenseModel.subscribe(tripId: tripId)
        }
        .onDisappear {
            expenseModel.unsubscribe()
        }
    } // body closing bracket
} // view closing bracket

#Preview {
    ExpensesView(tripId: "zXtPknz7e75wBCht7tZx")
}

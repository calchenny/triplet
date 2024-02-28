//
//  FoodPopupView.swift
//  Triplet
//
//  Created by Derek Ma on 2/27/24.
//

import SwiftUI

enum FoodCategory: String, CaseIterable {
    case breakfast = "Breakfast/Brunch"
    case lunch = "Lunch"
    case dinner = "Dinner"
}

struct FoodPopupView: View {
    @EnvironmentObject var overviewViewModel: OverviewViewModel
    @State var selection: FoodCategory = .breakfast
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .foregroundStyle(.white)
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            overviewViewModel.showFoodPopup.toggle()
                        } label: {
                            Circle()
                                .frame(maxWidth: 30)
                                .foregroundStyle(Color("Dark Blue"))
                                .overlay {
                                    Image(systemName: "xmark")
                                        .foregroundStyle(.white)
                                }
                        }
                    }
                    Text("New Food Spot")
                        .font(.custom("Poppins-Bold", size: 30))
                        .foregroundStyle(Color("Dark Blue"))
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Category")
                                .font(.custom("Poppins-Medium", size: 16))
                            Picker("Select a paint color", selection: $selection) {
                                ForEach(FoodCategory.allCases, id: \.self) { category in
                                    Text(category.rawValue)
                                }
                            }
                            .frame(maxWidth: 200)
                            .pickerStyle(.menu)
                            .tint(Color("Dark Blue"))
                            .padding(5)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color("Darker Gray")))
                        }
                        Spacer()
                    }
                    .padding()
                    Spacer()
                    Button {
                        
                    } label: {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 200, height: 50)
                            .foregroundStyle(Color("Dark Blue"))
                            .overlay(
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add food")
                                        .font(.custom("Poppins-Medium", size: 16))
                                }
                                .tint(.white)
                            )
                            .padding(.bottom)
                    }
                }
                .padding()
            )
            .padding()
            .frame(maxHeight: 500)
    }
}

#Preview {
    FoodPopupView()
        .environmentObject(OverviewViewModel())
}

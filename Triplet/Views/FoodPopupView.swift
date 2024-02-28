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
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.gray)
                        }
                    }
                    Text("New Food Spot")
                        .font(.title)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .foregroundStyle(.indigo)
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Category")
                                .font(.title3)
                            Picker("Select a paint color", selection: $selection) {
                                ForEach(FoodCategory.allCases, id: \.self) { category in
                                    Text(category.rawValue)
                                }
                            }
                            .frame(maxWidth: 200)
                            .pickerStyle(.menu)
                            .tint(.indigo)
                            .padding(5)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(.gray))
                        }
                        Spacer()
                    }
                    .padding()
                    Spacer()
                    Button {
                        
                    } label: {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 200, height: 50)
                            .foregroundStyle(.indigo)
                            .overlay(
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add food")
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

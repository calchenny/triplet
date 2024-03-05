//
//  FoodPopupView.swift
//  Triplet
//
//  Created by Derek Ma on 2/27/24.
//

import SwiftUI

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
                            Menu {
                                Picker("", selection: $selection) {
                                    ForEach(FoodCategory.allCases, id: \.self) { category in
                                        Text(category.rawValue)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selection.rawValue)
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .frame(minWidth: 150)
                                    Image(systemName: "chevron.down")
                                        .foregroundStyle(Color("Darker Gray"))
                                }
                            }
                            .frame(maxWidth: 200, maxHeight: 30)
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

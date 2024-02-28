//
//  FoodPopupView.swift
//  Triplet
//
//  Created by Derek Ma on 2/27/24.
//

import SwiftUI

struct FoodPopupView: View {
    @EnvironmentObject var overviewViewModel: OverviewViewModel
    
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
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.indigo)
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

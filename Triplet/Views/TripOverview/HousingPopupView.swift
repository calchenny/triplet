//
//  HousingPopupView.swift
//  Triplet
//
//  Created by Derek Ma on 2/28/24.
//

import SwiftUI

struct HousingPopupView: View {
    @EnvironmentObject var overviewViewModel: OverviewViewModel
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .foregroundStyle(.white)
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            overviewViewModel.showHousingPopup.toggle()
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
                    Text("New Hotel/Lodging")
                        .font(.custom("Poppins-Bold", size: 30))
                        .foregroundStyle(Color("Dark Blue"))
                    Spacer()
                    Button {
                        
                    } label: {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 200, height: 50)
                            .foregroundStyle(Color("Dark Blue"))
                            .overlay(
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add lodging")
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

//#Preview {
//    HousingPopupView()
//        .environmentObject(OverviewViewModel())
//}

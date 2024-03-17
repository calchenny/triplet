//
//  DestinationSearchView.swift
//  Triplet
//
//  Created by Calvin Chen on 2/20/24.
//

import SwiftUI
import MapKit

struct DestinationSearchView: View {
    @ObservedObject var locationSearchService = LocationSearchService()
    @EnvironmentObject var destinationViewModel: DestinationViewModel
    @Environment(\.dismiss) var dismiss
    
    func selectedDestination(result: LocationSearchService.CityResult) {
        print("Selected place: \(result.city)")
        // Store into model
        destinationViewModel.setDestination(city: result.city,
                                            state: result.state,
                                            country: result.country,
                                            latitude: result.latitude,
                                            longitude: result.longitude)
        dismiss()
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "xmark")
                        .font(.title3.weight(.semibold))
                        .padding(7)
                        .background(.darkTeal)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                })
                Spacer()
            }
            .padding()
            
                Form {
                    Section(header: Text("Location Search")
                        .font(.custom("Poppins-Regular", size: 14))) {
                        ZStack(alignment: .trailing) {
                            TextField("Search", text: $locationSearchService.searchQuery)
                                .font(.custom("Poppins-Regular", size: 16))
                            // Displays an icon during an active search
                            if locationSearchService.status == .isSearching {
                                Image(systemName: "clock")
                                    .foregroundColor(Color.gray)
                            }
                        }
                    }
                    .listRowBackground(Color(UIColor.systemGray6))
                    
                    Section(header: Text("Results")
                        .font(.custom("Poppins-Regular", size: 14))) {
                        List(locationSearchService.searchResults, id: \.self) { result in
                            Button(action: {
                                selectedDestination(result: result)
                            }) {
                                HStack {
                                    Text("\(result.city), \(result.state), \(result.country)")
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundStyle(.black)
                                }
                            }
                        }
                    }
                    .listRowBackground(Color(UIColor.systemGray6))
                }
                .background(.white)
                .scrollContentBackground(.hidden)
            }
    }
}

#Preview {
    DestinationSearchView(locationSearchService: LocationSearchService())
        .environmentObject(DestinationViewModel())
}

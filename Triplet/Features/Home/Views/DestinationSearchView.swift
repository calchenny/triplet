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
    @State private var searchQuery: String = ""
    @State private var displayedResults: [LocationSearchService.CityResult] = []
    @Binding var showDestinationPopup: Bool

    func selectedDestination(result: LocationSearchService.CityResult) {
        print("Selected place: \(result.city)")
        // Store into model
        destinationViewModel.setDestination(city: result.city,
                                            state: result.state,
                                            country: result.country,
                                            latitude: result.latitude,
                                            longitude: result.longitude)
        showDestinationPopup.toggle()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.white)
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showDestinationPopup.toggle()
                    }, label: {
                        Circle()
                            .frame(maxWidth: 30)
                            .foregroundStyle(Color("Dark Teal"))
                            .overlay {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.white)
                            }
                    })
                }
                .padding(.top)
                
                Form {
                    Section(header: Text("Location Search")
                        .font(.custom("Poppins-Regular", size: 14))) {
                        ZStack(alignment: .trailing) {
                            TextField("Search", text: $searchQuery)
                                .font(.custom("Poppins-Regular", size: 16))
                                .onChange(of: searchQuery) {
                                    // Update the locationSearchService when the text changes
                                    locationSearchService.searchQuery = searchQuery
                                    displayedResults = locationSearchService.searchResults // Update displayed results

                                }
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
                        List(displayedResults, id: \.self) { result in
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
            .padding([.leading, .trailing], 20)

        }
        .padding()
        .frame(maxHeight: 550)
    }
}

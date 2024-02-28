//
//  DestinationSearchView.swift
//  Triplet
//
//  Created by Calvin Chen on 2/20/24.
//

import SwiftUI
import MapKit

struct DestinationSearchView: View {
    @ObservedObject var locationSearch = LocationSearch()
    @EnvironmentObject var destinationViewModel: DestinationViewModel
    @Environment(\.dismiss) var dismiss
    
    func selectedDestination(result: LocationSearch.CityResult) async {
        print("Selected place: \(result.city)")
        
        // Store into model
        await destinationViewModel.setDestination(city: result.city,
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
                        .background(.gray)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 4, x: 0, y: 4)
                })
                Spacer()
            }
            .padding()
            
                Form {
                    Section(header: Text("Location Search")) {
                        ZStack(alignment: .trailing) {
                            TextField("Search", text: $locationSearch.searchQuery)
                            // Displays an icon during an active search
                            if locationSearch.status == .isSearching {
                                Image(systemName: "clock")
                                    .foregroundColor(Color.gray)
                            }
                        }
                    }
                    .listRowBackground(Color(UIColor.systemGray6))
                    
                    Section(header: Text("Results")) {
                        List(locationSearch.searchResults, id: \.self) { result in
                            Button(action: {
                                Task {
                                    await selectedDestination(result: result)
                                }
                            }) {
                                HStack {
                                    Text("\(result.city), \(result.state), \(result.country)")
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
    DestinationSearchView(locationSearch: LocationSearch())
        .environmentObject(DestinationViewModel())
}
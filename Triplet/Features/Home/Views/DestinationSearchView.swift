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
    @State private var displayedResults = [LocationSearchService.CityResult]()
    @State var selectedLandmark: LocationSearchService.CityResult?
    @State var showAlert: Bool = false
    @Binding var showDestinationPopup: Bool

    // Function to handle destination selection and then dismiss the popup
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
                ZStack(alignment: .trailing) {
                    HStack {
                        Text("Destination")
                            .font(.custom("Poppins-Bold", size: 30))
                            .foregroundStyle(.darkTeal)
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
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
                
                // Search bar implementation
                ZStack(alignment: .trailing) {
                    TextField("Search cities", text: $searchQuery)
                        .padding(20)
                        .frame(maxHeight: 35)
                        .font(.custom("Poppins-Regular", size: 16))
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color("Darker Gray")))
                        .onChange(of: searchQuery) {
                            // Trigger search on text change
                            locationSearchService.searchQuery = searchQuery
                            displayedResults = locationSearchService.searchResults
                        }
                    Image(systemName: "magnifyingglass")
                        .padding(.trailing)
                        .foregroundStyle(.darkerGray)
                }
                
                // Display the search results
                VStack(alignment: .leading) {
                    Text("\(displayedResults.count) Results")
                        .font(.custom("Poppins-Regular", size: 14))
                    ScrollView {
                        VStack(spacing: 5) {
                            // List each search result
                            ForEach(displayedResults, id: \.self) { landmark in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(landmark == selectedLandmark ? .lighterGray : .white)
                                    HStack {
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                            .padding(.trailing)
                                            .foregroundStyle(.darkTeal)
                                        VStack(alignment: .leading) {
                                            // Display city name
                                            Text(landmark.city)
                                                .font(.custom("Poppins-Regular", size: 14))
                                            // Display state and country
                                            Text("\(landmark.state), \(landmark.country)")
                                                .foregroundStyle(.darkerGray)
                                                .font(.custom("Poppins-Regular", size: 12))
                                        }
                                        Spacer()
                                    }
                                    .padding(5)
                                }
                                .onTapGesture {
                                    // Handle select or deselect a landmark
                                    selectedLandmark = selectedLandmark == landmark ? nil : landmark
                                }
                            }
                        }
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
                }
                .padding(.top)
                
                // Button to add the selected destination
                Button {
                    guard let selectedLandmark else {
                        showAlert.toggle() // Show alert message when nothing is selected
                        return
                    }
                    selectedDestination(result: selectedLandmark)
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 200, height: 40)
                        .foregroundStyle(Color("Dark Teal"))
                        .overlay(
                            HStack {
                                Image(systemName: "plus")
                                Text("Add destination")
                                    .font(.custom("Poppins-Medium", size: 16))
                            }
                                .tint(.white)
                        )
                        .padding([.top, .bottom])
                }
                // Alert configuration for when no destination is selected
                .alert("No Destination Selected", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Please select a destination")
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .padding()
        .frame(maxHeight: 500)
    }
}

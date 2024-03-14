//
//  FoodPopupView.swift
//  Triplet
//
//  Created by Derek Ma on 2/27/24.
//

import SwiftUI
import MapKit
import Firebase

struct FoodPopupView: View {
    @EnvironmentObject var overviewViewModel: OverviewViewModel
    @State var selectedFoodCategory: FoodCategory = .breakfast
    @State var location: String = ""
    @State var selectedLandmark: LandmarkViewModel?
    @State var landmarks: [LandmarkViewModel] = [LandmarkViewModel]()
    @State var showAlert: Bool = false
    
    private func getNearByLandmarks() {
        guard let trip = overviewViewModel.trip else {
            print("Missing trip")
            return
        }
        
        let request = MKLocalSearch.Request()
        request.pointOfInterestFilter = .includingAll
        request.naturalLanguageQuery = "\(location) \(trip.city) \(trip.state)"
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: trip.destination.latitude, longitude: trip.destination.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            if let response = response {
                self.landmarks = response.mapItems.compactMap { LandmarkViewModel(placemark: $0.placemark) }
            }
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.white)
            VStack {
                ZStack(alignment: .trailing) {
                    HStack {
                        Text("New Food Spot")
                            .font(.custom("Poppins-Bold", size: 30))
                            .foregroundStyle(Color("Dark Teal"))
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    Button {
                        overviewViewModel.showFoodPopup.toggle()
                    } label: {
                        Circle()
                            .frame(maxWidth: 30)
                            .foregroundStyle(Color("Dark Teal"))
                            .overlay {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.white)
                            }
                    }
                }
                .padding(.bottom)
                VStack(alignment: .leading) {
                    Text("Add a place")
                        .font(.custom("Poppins-Medium", size: 16))
                    ZStack(alignment: .trailing) {
                        TextField("Restaurant, Eatery, Etc.", text: $location)
                            .padding(20)
                            .frame(maxHeight: 35)
                            .font(.custom("Poppins-Regular", size: 16))
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color("Darker Gray")))
                            .onChange(of: location) {
                                getNearByLandmarks()
                            }
                        Image(systemName: "magnifyingglass")
                            .padding(.trailing)
                            .foregroundStyle(.darkerGray)
                    }
                }
                .padding([.leading, .trailing, .bottom])
                VStack(alignment: .leading) {
                    Text("\(landmarks.count) Results")
                        .font(.custom("Poppins-Regular", size: 14))
                    ScrollView {
                        VStack(spacing: 5) {
                            ForEach(landmarks) { landmark in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(landmark == selectedLandmark ? .lighterGray : .white)
                                    HStack {
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                            .padding(.trailing)
                                            .foregroundStyle(.darkTeal)
                                        VStack(alignment: .leading) {
                                            Text(landmark.name)
                                                .font(.custom("Poppins-Regular", size: 14))
                                            Text(landmark.title)
                                                .foregroundStyle(.darkerGray)
                                                .font(.custom("Poppins-Regular", size: 12))
                                        }
                                        Spacer()
                                    }
                                    .padding(5)
                                }
                                .onTapGesture {
                                    selectedLandmark = selectedLandmark == landmark ? nil : landmark
                                }
                            }
                        }
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 200)
                }
                .padding([.leading, .trailing])
                HStack {
                    VStack(alignment: .leading) {
                        Text("Category")
                            .font(.custom("Poppins-Medium", size: 16))
                            .padding(.top)
                        Menu {
                            Picker("", selection: $selectedFoodCategory) {
                                ForEach(FoodCategory.allCases, id: \.self) { category in
                                    Text(category.rawValue)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedFoodCategory.rawValue)
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .frame(minWidth: 150)
                                    .foregroundStyle(.black)
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(Color("Darker Gray"))
                            }
                        }
                        .frame(maxWidth: 200, maxHeight: 25)
                        .padding(5)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color("Darker Gray")))
                    }
                    Spacer()
                }
                .padding([.leading, .trailing])
                Button {
                    guard let selectedLandmark else {
                        showAlert.toggle()
                        return
                    }
                    overviewViewModel.addFoodPlace(name: selectedLandmark.name,
                                                   location: GeoPoint(latitude: selectedLandmark.coordinate.latitude, 
                                                                      longitude: selectedLandmark.coordinate.longitude),
                                                   address: selectedLandmark.title,
                                                   foodCategory: selectedFoodCategory)
                    overviewViewModel.showFoodPopup.toggle()
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 200, height: 40)
                        .foregroundStyle(Color("Dark Teal"))
                        .overlay(
                            HStack {
                                Image(systemName: "plus")
                                Text("Add food")
                                    .font(.custom("Poppins-Medium", size: 16))
                            }
                                .tint(.white)
                        )
                        .padding([.top, .bottom])
                }
                .alert("No Place Selected", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Please select a place")
                }
            }
            .padding()
        }
        .padding([.leading, .trailing])
        .frame(maxHeight: 600)
    }
}

#Preview {
    FoodPopupView()
        .environmentObject(OverviewViewModel())
}

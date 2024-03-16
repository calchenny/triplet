//
//  HousingPopupView.swift
//  Triplet
//
//  Created by Derek Ma on 2/28/24.
//

import SwiftUI
import MapKit
import Firebase

struct HousingPopupView: View {
    var tripId: String
    @EnvironmentObject var overviewViewModel: OverviewViewModel
    @EnvironmentObject var tripViewModel: TripViewModel
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State var location: String = ""
    @State var selectedLandmark: LandmarkViewModel?
    @State var landmarks: [LandmarkViewModel] = [LandmarkViewModel]()
    @State var showAlert: Bool = false
    
    private func getNearByLandmarks() {
        guard let trip = tripViewModel.trip else {
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
                        Text("New Housing")
                            .font(.custom("Poppins-Bold", size: 30))
                            .foregroundStyle(Color("Dark Teal"))
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    Button {
                        overviewViewModel.showHousingPopup.toggle()
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
                .padding(.top, 20)
                ZStack(alignment: .trailing) {
                    TextField("Search hotels, motels, etc.", text: $location)
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
                .padding(.bottom)
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
                    .frame(maxWidth: .infinity, maxHeight: 200)
                }
                if let trip = tripViewModel.trip,
                    let start = trip.start,
                    let end = trip.end {
                    DatePicker(selection: $startDate, in: start...end, displayedComponents: [.date, .hourAndMinute]) {
                        Text("Start:")
                            .font(.custom("Poppins-Medium", size: 16))
                    }
                    .tint(.darkTeal)

                    DatePicker(selection: $endDate, in: startDate...end, displayedComponents: [.date, .hourAndMinute]) {
                        Text("End:")
                            .font(.custom("Poppins-Medium", size: 16))
                    }
                    .tint(.darkTeal)
                    
                }
                Button {
                    guard let selectedLandmark else {
                        showAlert.toggle()
                        return
                    }
                    overviewViewModel.addHousingPlace(name: selectedLandmark.name,
                                                      location: GeoPoint(latitude: selectedLandmark.coordinate.latitude,
                                                                         longitude: selectedLandmark.coordinate.longitude),
                                                      address: selectedLandmark.title,
                                                      start: startDate,
                                                      end: endDate, tripId: tripId)
                    overviewViewModel.showHousingPopup.toggle()
                } label: {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 200, height: 50)
                        .foregroundStyle(Color("Dark Teal"))
                        .overlay(
                            HStack {
                                Image(systemName: "plus")
                                Text("Add lodging")
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
            .padding([.leading, .trailing], 20)
        }
        .padding()
        .frame(maxHeight: 600)
    }
}

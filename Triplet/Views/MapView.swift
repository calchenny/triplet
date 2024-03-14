//
//  MapView.swift
//  Triplet
//
//  Created by Calvin Chen on 2/29/24.
//

import SwiftUI
import MapKit
import CoreLocation


struct MapView: View {
    @ObservedObject var locationManager = LocationManager()
    @State private var mapSelection: String?
    @State private var selectedMarkerName: String?
    @State private var selectedMarker: MKMapItem = MKMapItem()
    @State private var showDetails: Bool = false
    @State private var alertMsg: String = ""
    @State var showError: Bool = false
    @State private var searchResults: [PointOfInterestResult] = []
    @State private var position = MapCameraPosition.userLocation(followsHeading: true, fallback: .automatic)
    @State private var route: MKRoute?
    @State private var distanceToMarker: Double?
    @Binding var showMapView: Bool

    func getCategoryData(category: String) -> (image: String, color: Color) {
        switch category {
        case "Hospitals":
            return ("drop.fill", .red)
        case "Police Stations":
            return ("shield.lefthalf.filled", .blue)
        case "Airport":
            return ("airplane", .mint)
        case "Hotels":
            return ("house", .brown)
        case "ATM":
            return ("creditcard", .green)
        case "Car Rental":
            return ("car", .orange)
        case "Public Transport":
            return ("bus", .gray)
        default:
            return ("questionmark", .darkerGray)
        }
    }
    
    struct PointOfInterestResult: Hashable, Identifiable {
        var id: String = UUID().uuidString
        var name: String
        var category: String
        var latitude: Double
        var longitude: Double
    }
    
    // Converts coordinates into an address
    func reverseGeocoding(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)

        // Look up the location and retrieve address
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil, let placemark = placemarks?.first else {
                alertMsg = "Failed to retrieve address: \(error?.localizedDescription ?? "Unknown error")"
                showError = true
                
                completion(nil)
                return
            }
            completion(placemark)
        }
    }
    
    // Search the area around the user for important point of interests
    func queryLocations() {
        let categories = ["Hospitals", "Police Stations", "Airport",
                          "Hotels", "ATM", "Car Rental", "Public Transport"]
        
        for category in categories {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = category
            // Filters so that only point of interests appears
            request.pointOfInterestFilter = .includingAll
            
            // Narrowing down the search to the region near the user
            request.region = locationManager.region
                        
            let search = MKLocalSearch(request: request)
            search.start {(response, error) in
                if let error = error {
                    alertMsg = "Error in query for category \(category): \(error.localizedDescription)"
                    showError = true
                    
                    return
                }
                if let response = response {
                    for item in response.mapItems {
                        if let location = item.placemark.location {
                            
                            if let userLocation = locationManager.currentLocation {
                                let distance = userLocation.distance(from: location)
                                
                                // Only display locations that are within 7.5 mile radius
                                if distance <= 12000 {
                                    let locationName = item.name ?? ""

                                    searchResults.append(PointOfInterestResult(name: locationName, category: category, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func fetchRouteFrom(destination: CLLocationCoordinate2D) {
        if let currentLocation = locationManager.currentLocation {

            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation.coordinate))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
            request.transportType = .automobile

            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                let distance = route?.distance
                
                if let magnitude = distance?.magnitude {
                    distanceToMarker = magnitude / 1609 // Conversion from meters to miles
                }
            }
        } else {
            alertMsg = "Unable to get route"
            showError = true
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                Map(position: $position, selection: $mapSelection) {
                    // Make an always viewable pin of the user's location
                    if let userLocation = locationManager.currentLocation {
                        Annotation("My location", coordinate: userLocation.coordinate) {
                            ZStack {
                                Circle()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/.opacity(0.25))
                                
                                Circle()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                                
                                Circle()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                            }
                        }
                    }
                                    
                    ForEach(searchResults, id: \.id) { result in
                        let categoryData = getCategoryData(category: result.category)
                        
                        Marker(result.name, systemImage: categoryData.image, coordinate: CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude))
                            .tint(Color(categoryData.color))
                    }
                }
                .onChange(of: mapSelection, { oldValue, newValue in
                    
                    if let selectedMarkerID = newValue {
                        // Find the selected Marker in the searchResults array using its ID
                        if let marker = searchResults.first(where: { $0.id == selectedMarkerID }) {
                            // Fetching distance from user to marker
                            fetchRouteFrom(destination: CLLocationCoordinate2D(latitude: marker.latitude, longitude: marker.longitude))
                            
                            // Extract name from selected Marker
                            selectedMarkerName = marker.name
                            
                            // Extract address from coordinates
                            reverseGeocoding(latitude: marker.latitude, longitude: marker.longitude) { placemark in
                                if let placemark = placemark {
                                    // Handle the retrieved placemark
                                    let marker = MKPlacemark(placemark: placemark)
                                    selectedMarker = MKMapItem(placemark: marker)

                                } else {
                                    // Handle the case where no placemark is found
                                    print("No Matching Address Found")
                                }
                            }
                        }
                    }
                    
                    showDetails = newValue != nil
                })
                .sheet(isPresented: $showDetails, content: {
                    VStack {
                        HStack {
                            VStack {
                                HStack {
                                    Text(selectedMarkerName ?? "")
                                        .font(.custom("Poppins-Bold", size: 18))
                                    
                                    Spacer()
                                    
                                    if let distance = distanceToMarker {
                                        Text("\(String(format: "%.2f", distance)) mi.")
                                            .font(.custom("Poppins-Regular", size: 12))
                                            .foregroundStyle(.darkerGray)
                                            .padding(.trailing)
                                            .multilineTextAlignment(.trailing)
                                        
                                    }
                                }
                                .padding(.bottom, 5)

                                HStack {
                                    Text(selectedMarker.placemark.title ?? "")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundStyle(.darkerGray)
                                    Spacer()
                                }

                            }
                            .padding(.horizontal, 30)
                            
                            Spacer()
                        }
                        
                        HStack(spacing: 24) {
                            Button {
                                selectedMarker.openInMaps()
                            } label: {
                                Text("Open in Maps")
                                    .font(.custom("Poppins-Bold", size: 16))
                                    .frame(width: 170, height: 36)
                                    .cornerRadius(10)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.darkBlue)

                        }
                        .padding(.vertical)
                    }
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.height(250)])
                    .presentationCornerRadius(15)
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(250)))
                })
                .mapControls {
                    // Adds UI functionality to the map
                    MapCompass()
                    MapPitchToggle()
                    MapUserLocationButton()
                    MapScaleView()
                }
                .mapStyle(.standard(showsTraffic: true))

            }
            .onAppear(perform: {
                Task {
                    queryLocations()
                }
            })
            
            VStack {
                HStack {
                    Button(action: {
                        showMapView.toggle()
                    }, label: {
                        Image(systemName: "arrowshape.backward.fill")
                            .font(.title3)
                            .padding(15)
                            .background(.darkBlue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4, x: 0, y: 4)
                    })
                    
                    Spacer()
                }
                .padding(.leading, 20)
                
                Spacer()
            }
            .padding(.top, 40)
            
            if showError {
                AlertView(msg: alertMsg, show: $showError)
            }
            
        }


    }
}

//
//#Preview {
//    MapView()
//}

//
//  MapView.swift
//  Triplet
//
//  Created by Calvin Chen on 2/29/24.
//

import SwiftUI
import MapKit
import CoreLocation
import TipKit

struct ToolTip: Tip {
    var title: Text {
        Text("Useful Map Tools")
    }
    
    var message: Text? {
        Text("Quickly move the camera to your destination or hide markers!")
    }
}

struct MapView: View {
     @ObservedObject var locationManagerService = LocationManagerService() // Observes changes in user's location
     
     @EnvironmentObject var tripViewModel: TripViewModel // Provides access to trip-related data
    
     @Environment(\.dismiss) var dismiss
     
     // State variables
     @State private var mapSelection: String?
     @State private var selectedMarkerName: String?
     @State private var selectedMarker: MKMapItem = MKMapItem()
     @State private var showDetails: Bool = false
     @State private var alertMsg: String = ""
     @State var showError: Bool = false
     @State private var searchResults: [PointOfInterestResult] = [] // Results of location search
     @State private var position = MapCameraPosition.userLocation(followsHeading: true, fallback: .automatic) // Camera position
     @State private var route: MKRoute?
     @State private var distanceToMarker: Double?
     @State var showMarkers: Bool = true
     @Binding var showMapView: Bool

    // Retrieves image and color data based on category
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
    
    // Represents a point of interest result
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
            request.region = locationManagerService.region
                        
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
                            
                            if let userLocation = locationManagerService.currentLocation {
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
    
    // Fetches route information from user's current location to a destination
    func fetchRouteFrom(destination: CLLocationCoordinate2D) {
        if let currentLocation = locationManagerService.currentLocation {

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
        ZStack(alignment: .topLeading) {
            VStack {
                Map(position: $position, selection: $mapSelection) {
                    // Display always-viewable pin of the user's location.
                    if let userLocation = locationManagerService.currentLocation {
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
                    
                    if showMarkers {
                        // Fetch events from the itinerary to display on the map.
                        if let trip = tripViewModel.trip, let events = trip.events {
                            ForEach(events, id: \.id) { event in
                              let destination = event.location
                                
                              Marker(event.name, systemImage: "flag.fill", coordinate: CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude))
                                    .tint(.darkTeal)
                            }
                        }
                        
                        // Displaying important locations near the user
                        ForEach(searchResults, id: \.id) { result in
                            let categoryData = getCategoryData(category: result.category)
                            
                            Marker(result.name, systemImage: categoryData.image, coordinate: CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude))
                                .tint(Color(categoryData.color))
                        }
                    }
                }
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                if let trip = tripViewModel.trip {
                                    let destination = trip.destination
                                    position = .camera(.init(centerCoordinate: CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude), distance: 50000))
                                }
                            } label: {
                                Circle()
                                    .frame(maxWidth: 25)
                                    .overlay {
                                        Image(systemName: "location.magnifyingglass")
                                            .foregroundStyle(.darkTeal)
                                            .padding()
                                            .background(Color.white.opacity(0.9))
                                            .foregroundColor(.black)
                                            .clipShape(Circle())
                                    }
                            }
                            .padding(.top, 18)
                            .padding(.trailing, 25)
                            
                            Button {
                                showMarkers.toggle()
                            } label: {
                                Circle()
                                    .frame(maxWidth: 25)
                                    .overlay {
                                        Image(systemName: showMarkers ? "eye.fill" : "eye.slash.fill")
                                            .foregroundStyle(.darkTeal)
                                            .padding()
                                            .background(Color.white.opacity(0.9))
                                            .foregroundColor(.black)
                                            .clipShape(Circle())
                                    }
                            }
                            .padding(.top, 18)
                            
                            Spacer()
                        }
                        .popoverTip(ToolTip(), arrowEdge: .top).tipBackground(.evenLighterBlue)
                    }
                    , alignment: .top
                )
                .onChange(of: mapSelection, { oldValue, newValue in
                    DispatchQueue.main.async {
                        if let selectedMarkerID = newValue {
                            print(selectedMarkerID)
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
                                selectedMarker.openInMaps() // Open the selected marker in Apple Maps
                            } label: {
                                Text("Open in Maps")
                                    .font(.custom("Poppins-Bold", size: 16))
                                    .frame(width: 170, height: 36)
                                    .cornerRadius(10)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.darkTeal)

                        }
                        .padding(.vertical)
                    }
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.height(250)])
                    .presentationCornerRadius(15)
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(250)))
                })
                .mapControls {
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
            
            Button {
                showMapView.toggle()
            } label: {
                Image(systemName: "arrowshape.backward.fill")
                    .font(.title2)
                    .padding()
                    .background(.darkTeal)
                    .foregroundColor(.white)
                    .clipShape(Circle())
            }
            .padding(.leading)
            .tint(.primary)
            
            if showError {
                AlertView(msg: alertMsg, show: $showError)
            }
        }
        .presentationCornerRadius(50)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: UIScreen.main.bounds.height * 0.87)

    }
}

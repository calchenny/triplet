//
//  MapView.swift
//  Triplet
//
//  Created by Calvin Chen on 2/29/24.
//

import SwiftUI
import MapKit


struct MapView: View {
    @ObservedObject var locationManager = LocationManager()
    @State private var mapSelection: String?
    @State private var selectedMarker: MKMapItem = MKMapItem()
    @State private var showDetails: Bool = false
    @State private var searchResults: [PointOfInterestResult] = []
    @State private var position = MapCameraPosition.userLocation(followsHeading: true, fallback: .automatic)
    
    // Hospitals, Police Station, Embassy, Hotels
    struct PointOfInterestResult: Hashable, Identifiable {
        var id: String = UUID().uuidString
        var name: String
        var category: String
        var latitude: Double
        var longitude: Double
    }
        
    // Marker selection
    struct MarkerModel: Identifiable {
        var id: String = UUID().uuidString
        var location: CLLocationCoordinate2D
        var title: String
    }
    
    func queryLocations() {
        let categories = ["Hospitals", "Police Stations", "Airport", 
                          "Hotel", "ATM", "Car Rental", "Public Transport"]
        
        for category in categories {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = category
            // Filters so that only point of interests appears
            request.pointOfInterestFilter = .includingAll
            
            // Narrowing down the search to the region near the user
            request.region = locationManager.region
                        
            let search = MKLocalSearch(request: request)
            search.start {(response, error) in
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
    
    var body: some View {
        VStack {
            Map(position: $position, selection: $mapSelection) {
                let markerImages: [String: String] = [
                    "Hospitals": "drop.fill",
                    "Police Stations": "shield.lefthalf.filled",
                    "Airport": "airplane",
                    "Hotels": "house",
                    "ATM": "creditcard",
                    "Car Rental": "car",
                    "Public Transport": "bus"
                    
                ]
                
                let markerColors: [String: Color] = [
                    "Hospitals": .red,
                    "Police Stations": .blue,
                    "Airport": .mint,
                    "Hotels": .brown,
                    "ATM": .green,
                    "Car Rental": .orange,
                    "Public Transport": .gray
                ]
                
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
                    
                    let category = markerImages[result.category] ?? "house"
                    
                    let markerColor = markerColors[result.category] ?? .blue
                    
                    Marker(result.name, systemImage: category, coordinate: CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude))
                        .tint(Color(markerColor))
                }
            }
            .onChange(of: mapSelection, { oldValue, newValue in
                
                if let selectedMarkerID = newValue {
                    // Find the selected Marker in the searchResults array using its ID
                    if let marker = searchResults.first(where: { $0.id == selectedMarkerID }) {
                        // Extract the coordinates of the selected Marker
                        let coordinates = CLLocationCoordinate2D(latitude: marker.latitude, longitude: marker.longitude)
                        selectedMarker = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
                        
                    }
                }
                
                showDetails = newValue != nil
            })
            .sheet(isPresented: $showDetails, content: {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(selectedMarker.name ?? "")
                                .font(.custom("Poppins-Medium", size: 32))

                        }
                        
                        Spacer()
                        
                        Button {
                            mapSelection = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.darkerGray, Color(.systemGray6))
                        }
                    }
                    HStack(spacing: 24) {
                        Button {
                            selectedMarker.openInMaps()
                        } label: {
                            Text("Open in Maps")
                                .font(.custom("Poppins-Regular", size: 24))
                                .frame(width: 170, height: 48)
                                .cornerRadius(10)
                        }

                    }
                }
                    .presentationDetents([.height(340)])
                    .presentationCornerRadius(12)
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
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

    }
}


#Preview {
    MapView()
}

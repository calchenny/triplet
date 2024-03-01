//
//  MapView.swift
//  Triplet
//
//  Created by Calvin Chen on 2/29/24.
//

import SwiftUI
import MapKit


struct MapView: View {
    @StateObject var userLocationModel = UserLocationViewModel()
    @ObservedObject var locationManager = LocationManager()
    @State private var landmarks: [LandmarkViewModel] = [LandmarkViewModel]()
    @State private var route: MKRoute?
    @State private var travelTime: String?
    private let gradient = LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
    private let stroke = StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round, dash: [8, 8])
    @State private var search: String = ""
    @State private var selectedTag: Int?
    @State private var searchResults: [PointOfInterestResult] = []
    @State private var position = MapCameraPosition.userLocation(followsHeading: true, fallback: .automatic)

    @State private var police = CLLocationCoordinate2D(latitude: 38.542296076131784, longitude: -121.75703415650757)
    @State private var hospital = CLLocationCoordinate2D(latitude: 38.56364488779553, longitude: -121.77041173429558)
    
    // Hospitals, Police Station, Embassy, Hotels
    struct PointOfInterestResult: Hashable {
        var name: String
        var category: String
        var latitude: Double
        var longitude: Double
    }
        
    func fetchRouteFrom(destination: CLLocationCoordinate2D) {
        if let currentLocation = locationManager.currentLocation {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: currentLocation.coordinate))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
            request.transportType = .walking
            
            Task {
                let result = try? await MKDirections(request: request).calculate()
                route = result?.routes.first
                getTravelTime()
            }
        } else {
            print("Unable to get route")
        }
    }
    
    func getTravelTime() {
        guard let route else { return }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        travelTime = formatter.string(from: route.expectedTravelTime)
    }
    
    func searchLocations() {
        let categories = ["Hospitals", "Police Stations"]
        
        for category in categories {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = category
            // Filters so that only point of interests appears
            request.pointOfInterestFilter = .includingAll
            
            let search = MKLocalSearch(request: request)
            search.start {(response, error) in
                if let response = response {
                    for item in response.mapItems {
                        if let location = item.placemark.location {
                            let locationName = item.name ?? ""

                            searchResults.append(PointOfInterestResult(name: locationName, category: category, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
                        }
                    }
                }
            }
        }
        
//        for result in searchResults {
//            print("\(result.name), category: \(result.category), latitude: \(result.latitude), longitude: \(result.longitude)")
//        }
    }
    
    var body: some View {
        VStack {
            
            Map(position: $position, selection: $selectedTag) {
                
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 8)
                }
                
                let markerImages: [String: String] = [
                    "Hospitals": "drop.fill",
                    "Police Stations": "shield.lefthalf.filled"
                ]
                
                let markerColors: [String: Color] = [
                    "Hospitals": .red,
                    "Police Stations": .blue
                ]
                
                ForEach(searchResults, id: \.self) { result in
                    
                    let category = markerImages[result.category] ?? "house"
                    
                    let markerColor = markerColors[result.category] ?? .blue
                    
                    Marker(result.name, systemImage: category, coordinate: CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude))
                        .tint(Color(markerColor))
                }
            }
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .mapStyle(.standard(showsTraffic: true))
            .overlay(alignment: .bottom, content: {
                HStack {
                    if let travelTime {
                        Text("Travel time: \(travelTime)")
                            .padding()
                            .font(.headline)
                            .foregroundStyle(.black)
                            .background(.ultraThinMaterial)
                            .cornerRadius(15)
                    }
                }
                .padding(.bottom)
            })


            TextField("Search for a place...", text: $search, onEditingChanged: { _ in}) {
                self.searchLocations()
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal, 50)
            .padding(.vertical, 20)
            .padding(.bottom, 10)
            
            Button {
                fetchRouteFrom(destination: hospital)
            } label: {
                Text("Start Planning")
                    .fontWeight(.heavy)
                    .padding(5)
                    .frame(width: UIScreen.main.bounds.width/1.5, alignment: .center)
            }
            .cornerRadius(15)
            .buttonStyle(.borderedProminent)
            .padding(.vertical)
            .tint(.gray)
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: {
            searchLocations()
        })

    }
}

#Preview {
    MapView()
}

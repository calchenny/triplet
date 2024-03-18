//
//  ActiveTripView.swift
//  Triplet
//
//  Created by Andy Lam on 3/13/24.
//

import SwiftUI
import EventKit
import ScalingHeaderScrollView
import PopupView
import MapKit
import CoreLocation
import FirebaseFirestore

struct ActiveTripView: View {
    var tripId: String
    @StateObject var itineraryModel = ItineraryViewModel()
    @EnvironmentObject var tripViewModel: TripViewModel
    
    @State var isExpanded = false
    @State var searchText: String = ""
    @State private var checkedEvents: Set<String> = []
    @State var isChecked = false
    @State var currentDate: Date = Date.now
    @State var showMapView: Bool = false
    @State var showAddEventSheet: Bool = false
    @State var navigateToHome: Bool = false
    @State private var reverseGeocodedAddress: String = ""
    private let timer = Timer.publish(every: 60, on: .main, in: .default).autoconnect()
    
    // Function to toggle event check
    private func toggleEventCheck(eventID: String) {
        if checkedEvents.contains(eventID) {
            checkedEvents.remove(eventID)
        } else {
            checkedEvents.insert(eventID)
        }
    }
    
    // Function to refresh the screen if current time matches an event's start or end time
    private func refreshScreenIfNeeded() {
        let currentTime = Date()
        let events = itineraryModel.events.filter { event in
            // Check if current time matches event's start or end time
            return currentTime >= event.start && currentTime <= event.end
        }
        
        if !events.isEmpty {
            // Refresh the screen if the current time matches any event's start or end time
            currentDate = Date()
        }
    }
    
    // Function to check if current time is within event start and end time
    func isCurrentTimeWithinEventTime(event: Event) -> Bool {
        let currentTime = Date()
        return currentTime >= event.start && currentTime <= event.end
    }
    
    func getCategoryImageName(category: String) -> String {
        switch category {
        case "Food":
            return "fork.knife.circle"
        case "Attraction":
            return "star"
        case "House":
            return "house"
        case "Transit":
            return "bus"
        default:
            return "questionmark"
        }
    }

    func reverseGeocoding(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)

        // Look up the location and retrieve address
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil, let placemark = placemarks?.first else {
                print("Failed to retrieve address:", error?.localizedDescription ?? "Unknown error")
                completion(nil)
                return
            }
            completion(placemark)
        }
    }
    
        
    var body: some View {
        VStack {
            Text("Today")
                .font(.custom("Poppins-Bold", size: 30))
                .foregroundStyle(Color.darkTeal)
                .padding(.top, 25)
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 40)
                .foregroundStyle(.evenLighterBlue)
                .overlay(
                    HStack {
                        Spacer()
                        Text("\(getDayOfWeek(currentDate)), \(getDateString(date: currentDate))") // Convert Date to String
                            .font(.custom("Poppins-Bold", size: 20))
                            .foregroundStyle(Color.darkTeal)
                        Spacer()
                    }
                )
                .padding(.bottom, 25)
                .padding([.leading, .trailing])
            Text("Happening Now:")
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundStyle(.darkerGray)
            ForEach(itineraryModel.events.filter { Calendar.current.isDate($0.start, inSameDayAs: currentDate) && $0.end > Date() }, id: \.id) { event in
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(isCurrentTimeWithinEventTime(event: event) ? .lighterGray : .clear)
                    VStack {
                        HStack {
                            // Image for the event's category
                            Image(systemName: getCategoryImageName(category: event.type.rawValue))
                                .resizable()
                                .frame(width: 30, height: 30)
                                .padding([.leading, .trailing])
                                .foregroundColor(.darkTeal)
                            
                            Divider()
                                .frame(width: 2)
                                .backgroundStyle(.darkerGray)
                            
                            // Event details
                            VStack(alignment: .leading) {
                                Text(event.name)
                                    .font(.custom("Poppins-Medium", size: 16))
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("\(getDateString(date: event.start, includeTime: true)) - \(getDateString(date: event.end, includeTime: true))")
                                    .font(.custom("Poppins-Regular", size: 12))
                                Text(event.address)
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundStyle(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                            Spacer()
                            // Checkbox (Toggle) for the current event
                            Button(action: {
                                toggleEventCheck(eventID: event.id ?? "")
                            }) {
                                Image(systemName: checkedEvents.contains(event.id ?? "") ? "checkmark.square.fill" : "square")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.darkTeal)
                            }
                        }
                        if event.start < Date() {
                            let location = event.location
                            let latitude = location.latitude
                            let longitude = location.longitude
                            testAPICallsView(eventName: event.name, longitude: longitude, latitude: latitude, term: event.type.rawValue)
                        }
                    }
                    .padding()
                }
                .padding([.leading, .trailing])
                .padding(.bottom, 10)
            }
        }
        .onAppear {
            itineraryModel.subscribe(tripId: tripId)
        }
        .onDisappear {
            itineraryModel.unsubscribe()
        }
    }
            
}

#Preview {
    ActiveTripView(tripId: "xv5hwNz7WaYCUlxWLMTX")
}

//
//  DayOfView.swift
//  Triplet
//
//  Created by Andy Lam on 3/13/24.
//

import SwiftUI
import EventKit
import ScalingHeaderScrollView
import MapKit
import CoreLocation
import FirebaseFirestore

struct DayOfView: View {
    @StateObject var itineraryModel = ItineraryViewModel()
    @EnvironmentObject var userModel: UserModel
    
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
    var tripId: String
    
    init(tripId: String) {
        self.tripId = tripId
    }
    
    func getDayOfWeek(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
    
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
    
    func getHeaderWidth(screenWidth: CGFloat) -> CGFloat {
        let maxWidth = screenWidth * 0.9
        let minWidth = screenWidth * 0.5
        return max((1 - itineraryModel.collapseProgress + 0.5 * itineraryModel.collapseProgress) * maxWidth, minWidth)
    }
    
    func getHeaderHeight() -> CGFloat {
        let maxHeight = CGFloat(100)
        let minHeight = CGFloat(30)
        return max((1 - itineraryModel.collapseProgress + 0.5 * itineraryModel.collapseProgress) * maxHeight, minHeight)
    }
    
    func getHeaderTitleSize() -> CGFloat {
        let maxSize = CGFloat(30)
        let minSize = CGFloat(16)
        return max((1 - itineraryModel.collapseProgress + 0.5 * itineraryModel.collapseProgress) * maxSize, minSize)
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

    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd" // Customize the format as needed
        return dateFormatter.string(from: date)
    }

    func formatTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a" // Customize the format as needed
        return dateFormatter.string(from: date)
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
        GeometryReader { geometry in
            ScalingHeaderScrollView {
                ZStack(alignment: .topLeading) {
                    ZStack(alignment: .bottom) {
                        Map(position: Binding(
                            get: {
                                guard let cameraPosition = itineraryModel.cameraPosition else {
                                    return MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 47.608013, longitude: -122.335167), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
                                }
                                return cameraPosition
                            },
                            set: { itineraryModel.cameraPosition = $0 }
                        ), interactionModes: [])
                        .onTapGesture {
                            showMapView = true
                        }
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: getHeaderWidth(screenWidth: UIScreen.main.bounds.width), height: getHeaderHeight())
                            .foregroundStyle(.evenLighterBlue)
                            .overlay(
                                VStack {
                                    if let trip = itineraryModel.trip {
                                        Text(trip.name)
                                            .font(.custom("Poppins-Bold", size: getHeaderTitleSize()))
                                            .foregroundStyle(Color("Dark Teal"))
                                        Text("\(trip.city), \(trip.state) | \(getDateString(date: trip.start)) - \(getDateString(date: trip.end))")
                                            .font(.custom("Poppins-Medium", size: 13))
                                            .foregroundStyle(Color("Dark Teal"))
                                    }
                                }
                            )
                            .padding(.bottom, 30)
                    }
                    Button {
                        navigateToHome = true
                    } label: {
                        Image(systemName: "house")
                            .font(.title2)
                            .padding()
                            .background(Color("Dark Teal"))
                            .foregroundStyle(.white)
                            .clipShape(Circle())
                    }
                    .padding(.top, 60)
                    .padding(.leading)
                    .tint(.primary)
                }
                .frame(maxWidth: .infinity)
            } content: {
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
                                Text( "\(getDayOfWeek(currentDate)), \(formatDate(currentDate))") // Convert Date to String
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
                    ForEach(itineraryModel.events.filter { Calendar.current.isDate($0.start, inSameDayAs: currentDate) && $0.end > Date() }) { event in
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
                                        Text("\(formatTime(event.start)) - \(formatTime(event.end))")
                                            .font(.custom("Poppins-Regular", size: 12))
                                        Text(event.address)
                                            .font(.custom("Poppins-Regular", size: 12))
                                            .foregroundStyle(.secondary)
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
                                .frame(maxHeight: 100)
                                if event.start < Date() {
                                    let location = event.location
                                    let latitude = location.latitude
                                    let longitude = location.longitude
                                    testAPICallsView(longitude: longitude, latitude: latitude, term: event.type.rawValue)
                                }
                            }
                            .padding()
                        }
                        .padding([.leading, .trailing])
                        .padding(.bottom, 10)
                    }
                }
                
            }
            .height(min: itineraryModel.minHeight, max: itineraryModel.maxHeight)
            .allowsHeaderCollapse()
            .collapseProgress($itineraryModel.collapseProgress)
            .setHeaderSnapMode(.immediately)
            .ignoresSafeArea()
            .onAppear {
                itineraryModel.subscribe(tripId: tripId)
            }
            .onDisappear {
                itineraryModel.unsubscribe()
            }
        }
        .navigationDestination(isPresented: $navigateToHome) {
            NavigationStack{
                HomeView()
            }
            .navigationBarBackButtonHidden(true)
        }
        .onReceive(timer) { _ in
            
            refreshScreenIfNeeded()
        }
    }
            
}

#Preview {
    DayOfView(tripId: "xv5hwNz7WaYCUlxWLMTX")
}

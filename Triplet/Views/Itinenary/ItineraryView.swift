//
//  ItineraryView.swift
//  Triplet
//
//  Created by Andy Lam on 2/20/24.
//

import SwiftUI
import EventKit
import ScalingHeaderScrollView
import PopupView
import MapKit
import CoreLocation
import FirebaseFirestore

struct ItineraryView: View {
    
    @StateObject var itineraryModel = ItineraryViewModel()
    @EnvironmentObject var userModel: UserModel
    @State var navigateToHome: Bool = false
    @State var goToDayView = false
    @State var searchText: String = ""
    @State var showMapView: Bool = false
    @State var showAddEventSheet: Bool = false
    
    @State private var reverseGeocodedAddress: String = ""
    
    var tripId: String
    
    init(tripId: String) {
        self.tripId = tripId
    }
    
    func getHeaderWidth(screenWidth: CGFloat) -> CGFloat {
        let maxWidth = screenWidth * 0.9
        let minWidth = screenWidth * 0.5
        return max((1 - itineraryModel.collapseProgress + 0.5 * itineraryModel.collapseProgress) * maxWidth, minWidth)
    }
    
    func getHeaderHeight() -> CGFloat {
        let maxHeight = CGFloat(100)
        let minHeight = CGFloat(60)
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

    func datesInRange(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        
        let calendar = Calendar.current
        
        while currentDate <= endDate {
            dates.append(currentDate)
            
            guard let day = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                return [Date()]
            }
            
            currentDate = day
        }
        if !dates.contains(endDate) {
            dates.append(endDate)
        }
        return dates
    }
    
    func dayOfWeek(_ date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday], from: date)
        guard let weekday = components.weekday else { return "" }
        
        // Get the day of the week name from the weekday number
        let dayName = calendar.weekdaySymbols[weekday - 1].capitalized
        return dayName
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
            Text("Itinerary")
                .font(.custom("Poppins-Bold", size: 30))
                .foregroundStyle(Color.darkTeal)
                .padding(.top, 25)
            Button(action: {
                showAddEventSheet.toggle()
            }) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 200, height: 40)
                    .foregroundStyle(Color("Dark Teal"))
                    .overlay(
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Event")
                                .font(.custom("Poppins-Medium", size: 16))
                        }
                            .tint(.white)
                    )
                    .padding(.bottom, 30)
            }
            .sheet(isPresented: $showAddEventSheet) {
                AddPlaceView()
                    .presentationDragIndicator(.visible)
                    .environmentObject(itineraryModel)
            }
            
            if itineraryModel.events.isEmpty {
                Text("No events planned yet!")
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.darkerGray)
                    .padding()
                    .padding(.top, 10)
            } else {
                ScrollView {
                    if let trip = itineraryModel.trip,
                       let start = trip.start,
                       let end = trip.end {
                        
                        let rangeOfDates = datesInRange(from: start, to: end)
                        
                        ForEach(rangeOfDates, id: \.self) { day in
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: .infinity, height: 40)
                                .foregroundStyle(.evenLighterBlue)
                                .overlay(
                                    HStack {
                                        Spacer()
                                        Text( "\(dayOfWeek(day)), \(formatDate(day))") // Convert Date to String
                                            .font(.custom("Poppins-Bold", size: 20))
                                            .foregroundStyle(Color.darkTeal)
                                        Spacer()
                                    }
                                )
                                .padding([.leading, .trailing, .bottom])
                            
                            VStack(alignment: .leading) {
                                if itineraryModel.events.filter({formatDate($0.start) == formatDate(day)}).isEmpty {
                                    Text("No events planned.")
                                        .font(.custom("Poppins-Regular", size: 14))
                                } else {
                                    ForEach(itineraryModel.events.filter({formatDate($0.start) == formatDate(day)})) { event in
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
                                            Button {
                                                itineraryModel.deleteEventFromFirestore(eventID: event.id ?? "")
                                            } label: {
                                                Image(systemName: "trash")
                                                    .font(.title2)
                                                    .padding()
                                                    .foregroundStyle(.darkerGray)
                                            }
                                            .tint(.primary)
                                        }
                                        .padding([.leading, .trailing], 20)
                                    }
                                }
                            }
                            .padding(.bottom, 20)
                        }
                    }
                }
                .navigationDestination(isPresented: $navigateToHome) {
                    NavigationStack{
                        HomeView()
                    }
                    .navigationBarBackButtonHidden(true)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .height(min: itineraryModel.minHeight, max: itineraryModel.maxHeight)
        .allowsHeaderCollapse()
        .collapseProgress($itineraryModel.collapseProgress)
        .setHeaderSnapMode(.immediately)
        .ignoresSafeArea(edges: .top)
        .popup(isPresented: $showMapView) {
            MapView(showMapView: $showMapView)
                .navigationBarBackButtonHidden(true)
        } customize: { popup in
            popup
                .appearFrom(.top)
                .type(.default)
                .position(.center)
                .animation(.easeIn)
                .closeOnTap(false)
                .closeOnTapOutside(false)
                .useKeyboardSafeArea(true)
                .isOpaque(true)
                .backgroundColor(.black.opacity(0.25))
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
    ItineraryView(tripId: "zXtPknz7e75wBCht7tZx")
}

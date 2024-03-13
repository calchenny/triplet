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
    @State var showAddEventSheet: Bool = false
    
    @State private var reverseGeocodedAddress: String = ""
    
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
        let maxHeight = CGFloat(80)
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
                        Map(position: $itineraryModel.cameraPosition)
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: getHeaderWidth(screenWidth: geometry.size.width), height: getHeaderHeight())
                            .foregroundStyle(.evenLighterBlue)
                            .overlay(
                                VStack {
                                    Text("Most Amazing Trip") // CHANGE THIS
                                        .font(.custom("Poppins-Bold", size: getHeaderTitleSize()))
                                        .foregroundStyle(Color.darkBlue)
                                    Text("Seattle, WA | 3/13 - 3/17") // CHANGE THIS
                                        .font(.custom("Poppins-Regular", size: 15))
                                        .foregroundStyle(.darkBlue)
                                }
                            )
                            .padding(.bottom, 30)
                    }
                    Button {
                    } label: {
                        Image(systemName: "house")
                            .font(.title2)
                            .padding()
                            .background(Color("Dark Blue"))
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
                    HStack {
                        Text("\(getDayOfWeek(currentDate)), \(formatDate(currentDate))")
                            .font(.custom("Poppins-Bold", size: 30))
                            .foregroundStyle(Color.darkBlue)
                    }
                    .padding(.top, 20)
                    ForEach(itineraryModel.events.filter {Calendar.current.isDate($0.start, inSameDayAs: currentDate)}) { event in
                        
                        HStack(spacing: 20) {
                            // Image for the event's category
                            Image(systemName: getCategoryImageName(category: event.type.rawValue))
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.darkBlue)
                            
                            // Event details
                            VStack(alignment: .leading){
                                Text(event.name)
                                    .font(.custom("Poppins-Bold", size: 20))
                                    .foregroundStyle(Color.darkBlue)
                                Text("\(formatTime(event.start)) - \(formatTime(event.end))")
                                    .font(.custom("Poppins-Bold", size: 15))
                                Text(event.address)
                                    .font(.custom("Poppins-Regular", size: 13))
                            }
                            .padding()
                            Spacer()
                            // Checkbox (Toggle) for each event
                            Button(action: {
                                toggleEventCheck(eventID: event.id ?? "")
                            }) {
                                Image(systemName: checkedEvents.contains(event.id ?? "") ? "checkmark.square" : "square")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.darkBlue)
                            }
                           
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white)
                                .shadow(color: (isCurrentTimeWithinEventTime(event: event) ? .darkBlue : .clear), radius: 5, x: 0, y: 2)
                        )
                        
                    }
                    .padding()
                }
                
            }
            .height(min: itineraryModel.minHeight, max: itineraryModel.maxHeight)
            .allowsHeaderCollapse()
            .collapseProgress($itineraryModel.collapseProgress)
            .setHeaderSnapMode(.immediately)
            .ignoresSafeArea()
            .onAppear {
                itineraryModel.subscribe()
            }
            .onDisappear {
                itineraryModel.unsubscribe()
            }
        }
    }
            
}

#Preview {
    DayOfView()
}

//
//  ItineraryView.swift
//  Triplet
//
//  Created by Andy Lam on 2/20/24.
//

import SwiftUI
import EventKit
import ScalingHeaderScrollView
import MapKit
import CoreLocation
import FirebaseFirestore

struct ItineraryView: View {
    
    @StateObject var itineraryModel = ItineraryViewModel()
    @EnvironmentObject var userModel: UserModel
    
    @State var isExpanded = false
    @State var searchText: String = ""
    
    @State var showAddEventSheet: Bool = false
    
    @State private var reverseGeocodedAddress: String = ""
    
    
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
                                    Text("Seattle, WA | 10/20 - 10/25") // CHANGE THIS
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
                Text("Itinerary")
                    .font(.custom("Poppins-Bold", size:30))
                    .foregroundStyle(Color.darkBlue)
                    .padding(10)
                Button(action: {
                    showAddEventSheet.toggle()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Add an Event")
                            .font(.custom("Poppins-Regular", size:15))
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.darkBlue)
                    .cornerRadius(10)
                }
                .padding(.bottom, 5)
                .padding(.top, 10)
                .sheet(isPresented: $showAddEventSheet) {
                    AddPlaceView()
                        .environmentObject(itineraryModel)
                }
                
                if itineraryModel.events.isEmpty {
                    Text("No events planned yet!")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        
                        ForEach(["10/20", "10/21", "10/22", "10/23", "10/24", "10/25"], id: \.self) { day in // CHANGE THIS
                            
                            HStack {
                                Spacer()
                                Text(day)
                                    .font(.custom("Poppins-Bold", size:20))
                                    .foregroundStyle(Color.darkBlue)
                                Spacer()
                            }
                            .background(Color.evenLighterBlue)
                            .cornerRadius(20)
                            .frame(maxWidth: .infinity)
                            VStack {
                                if itineraryModel.events.filter({formatDate($0.start) == day}).isEmpty {
                                    Text("No events planned.")
                                        .font(.custom("Poppins-Regular", size: 13))
                                } else {
                                    ForEach(itineraryModel.events.filter({formatDate($0.start) == day})) { event in
                                        HStack(spacing: 10) {
                                            // Image for the event's category
                                            Image(systemName: getCategoryImageName(category: event.type.rawValue))
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.darkBlue)
                                            
                                            Divider()
                                                .frame(width: 2)
                                                .background(Color.darkBlue)
                                            
                                            // Event details
                                            VStack(alignment: .leading) {
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
                                            Button {
                                                itineraryModel.deleteEventFromFirestore(eventID: event.id ?? "")
                                            } label: {
                                                Image(systemName: "trash")
                                                    .font(.title2)
                                                    .padding()
                                                    .background(Color("Dark Blue"))
                                                    .foregroundStyle(.white)
                                                    .clipShape(Circle())
                                            }
                                            .padding(.leading)
                                            .tint(.primary)
                                        }
                                        .padding(20)
                                    }
                                }
                            }
                            .padding(.bottom, 20)
                        }
                    }
                    .frame(maxWidth: .infinity)
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
    ItineraryView()
}

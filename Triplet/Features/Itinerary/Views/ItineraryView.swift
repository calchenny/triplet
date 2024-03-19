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
    var tripId: String
    @StateObject var itineraryModel = ItineraryViewModel()
    @EnvironmentObject var tripViewModel: TripViewModel

    @State var goToDayView = false
    @State var searchText: String = ""
    @State private var reverseGeocodedAddress: String = ""
    
    
    //function to grab image from sfsymbols
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
    
    
    var body: some View {
        VStack {
            Text("Itinerary")
                .font(.custom("Poppins-Bold", size: 30))
                .foregroundStyle(Color.darkTeal)
                .padding(.top, 25)
            Button(action: {
                itineraryModel.showNewPlacePopUp.toggle()
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
            .popup(isPresented: $itineraryModel.showNewPlacePopUp) {
                AddPlaceView(tripId: tripId)
                    .environmentObject(itineraryModel)
            } customize: { popup in
                popup
                    .type(.floater())
                    .position(.center)
                    .animation(.spring())
                    .closeOnTap(false)
                    .closeOnTapOutside(false)
                    .isOpaque(true)
                    .backgroundColor(.black.opacity(0.25))
            }
            .padding()
            
            if itineraryModel.events.isEmpty {
                Text("No events planned yet!")
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.darkerGray)
                    .padding()
                    .padding(.top, 10)
            } else {
                VStack {
                    // grab trip information from trip model and then display some details about trip
                    if let trip = tripViewModel.trip {
                        let rangeOfDates = datesInRange(from: trip.start, to: trip.end)
                        ForEach(rangeOfDates, id: \.self) { day in
                            VStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(height: 40)
                                    .foregroundStyle(.evenLighterBlue)
                                    .overlay(
                                        HStack {
                                            Spacer()
                                            Text( "\(getDayOfWeek(day)), \(getDateString(date: day))") // Convert Date to String
                                                .font(.custom("Poppins-Bold", size: 20))
                                                .foregroundStyle(Color.darkTeal)
                                            Spacer()
                                        }
                                    )
                                    .padding([.leading, .trailing, .bottom])
                                
                                VStack(alignment: .leading) {
                                    if itineraryModel.events.filter({getDateString(date: $0.start) == getDateString(date: day)}).isEmpty {
                                        Text("No events planned.")
                                            .font(.custom("Poppins-Regular", size: 14))
                                    } else {
                                        ForEach(itineraryModel.events.filter { getDateString(date: $0.start) == getDateString(date: day) }, id: \.id) { event in
                                            HStack {
                                                // Image for the event's category
                                                Image(systemName: getCategoryImageName(category: event.type.rawValue))
                                                    .font(.title)
                                                    .padding([.leading, .trailing])
                                                    .foregroundColor(.darkTeal)
                                                
                                                Divider()
                                                    .frame(width: 2)
                                                    .backgroundStyle(.darkerGray)
                                                
                                                // Event details
                                                VStack(alignment: .leading) {
                                                    Text(event.name)
                                                        .font(.custom("Poppins-Medium", size: 16))
                                                    Text("\(getDateString(date: event.start, includeTime: true)) - \(getDateString(date: event.end, includeTime: true))")
                                                        .font(.custom("Poppins-Regular", size: 12))
                                                    Text(event.address)
                                                        .font(.custom("Poppins-Regular", size: 12))
                                                        .foregroundStyle(.secondary)
                                                }
                                                .padding()
                                                Spacer()
                                                Button {
                                                    itineraryModel.deleteEventFromFirestore(eventID: event.id ?? "", tripId: tripId)
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
                }
            }
        }
        // activate listener 
        .onAppear {
            itineraryModel.subscribe(tripId: tripId)
        }
        // deactivate listener
        .onDisappear {
            itineraryModel.unsubscribe()
        }
    }
}



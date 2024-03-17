//
//  MyTripsView.swift
//  Triplet
//
//  Created by Xiaolin Ma on 2/21/24.
//

import SwiftUI
import CoreLocation

struct MyTripsView: View {
    @Binding var selectedIndex: Int
    @State var tabSelection = 0
    @StateObject var myTripsViewModel: MyTripsViewModel = MyTripsViewModel()
    @State var tripCities: [String] = []
    @State var tripStates: [String] = []
    @State var isTripsLoading = true
    
    var body: some View {
        VStack {
            Image(.fullIcon)
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.40, alignment: .center)
            VStack(alignment: .leading) {
                Text("My Trips")
                    .font(.custom("Poppins-Bold", size: 24))
                    .foregroundStyle(.darkTeal)
                Picker("", selection: $tabSelection) {
                    Text("Upcoming Trips")
                        .font(.custom("Poppins-Regular", size: 15))
                        .foregroundColor(.darkTeal)
                        .tag(0)
                        
                    Text("Past Trips")
                        .font(.custom("Poppins-Regular", size: 15))
                        .foregroundColor(.darkTeal)
                        .tag(1)
                        
                }
                .background(Color.evenLighterBlue)
                .pickerStyle(.segmented)
                .frame(width: UIScreen.main.bounds.width * 0.80)
            }
            Group {
                if tabSelection == 0 {
                    CurrentTripsView(selectedIndex: $selectedIndex, isTripsLoading: $isTripsLoading)
                } else {
                    PastTripsView(isTripsLoading: $isTripsLoading)
                }
            }
            .environmentObject(myTripsViewModel)

            Spacer()
        }
        .onAppear() {
            myTripsViewModel.subscribe() {
                withAnimation {
                    isTripsLoading.toggle()
                }
            }
        }
        .onDisappear {
            myTripsViewModel.unsubscribe() {
                withAnimation {
                    isTripsLoading.toggle()
                }
            }
        }
    }
}


struct NoTripPlanned: View {
    @Binding var selectedIndex: Int
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.evenLighterBlue)
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 200)
                VStack {
                    Text("No trip planned")
                        .padding(.bottom, 20)
                        .foregroundColor(.darkerGray)
                        .font(.custom("Poppins-Bold", size: 24))
                    Button {
                        selectedIndex = 1
                    } label: {
                        Text("Create a trip to get started")
                            .font(.custom("Poppins-Regular", size: 15))
                    }
                    .padding(15)
                    .background(.darkTeal)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
                .padding(25)
            }
            Spacer()
        }
    }
}

func getTripDuration(start: Date?, end: Date?) -> Int {
    guard let start else {
        return 0
    }
    guard let end else {
        return 0
    }
    
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day], from: start, to: end)
    guard let day = components.day else {
        print("Can't get day from component")
        return 0
    }
    return day + 1
    
}

func getDaysUntilTrip(start: Date?) -> Int {
    guard let start else {
        return 0
    }
    let currentDate = Date() // Initialize to today
    
    let calendar = Calendar.current
    let components1 = calendar.dateComponents([.year, .month, .day], from: currentDate)
    let components2 = calendar.dateComponents([.year, .month, .day], from: start)
    let components = calendar.dateComponents([.day], from: currentDate, to: start)
    // Compare dates
    if components1.year == components2.year &&
       components1.month == components2.month &&
       components1.day == components2.day {
        return 0
    }
    
    guard let day = components.day else {
        print("Can't get day from component")
        return 0
    }
    return day
    
}

struct CurrentTripsView: View  {
    @EnvironmentObject var myTripsViewModel: MyTripsViewModel
    @Binding var selectedIndex: Int
    @State private var navigateToOverview: Bool = false
    @State private var tripID: String = ""
    @State private var isActive: Bool = false
    @Binding var isTripsLoading: Bool
    
    var body: some View {
        VStack {
            if isTripsLoading {
                ProgressView()
                    .controlSize(.large)
            } else {
                Text("You have \(myTripsViewModel.currentTrips.count) trips planned.")
                    .font(.custom("Poppins-Regular", size: 16))
                    .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .leading)
                    .padding()
                if myTripsViewModel.currentTrips.count == 0 {
                    NoTripPlanned(selectedIndex: $selectedIndex)
                } else {
                    ScrollView {
                        ForEach(myTripsViewModel.currentTrips, id: \.id) { trip in
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.lighterGray)
                                    .frame(width: UIScreen.main.bounds.width * 0.8, height:120)
                                HStack {
                                    VStack (alignment: .leading) {
                                        Text(trip.name)
                                            .font(.custom("Poppins-Bold", size: 16))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundStyle(.darkTeal)
                                        Text("\(trip.city), \(trip.state)")
                                            .font(.custom("Poppins-Regular", size: 12))
                                            .padding(.bottom, 5)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        HStack {
                                            Text("\(getDateString(date: trip.start)) - \(getDateString(date: trip.end))")
                                                .font(.custom("Poppins-Regular", size: 12))
                                            
                                            Text("(\(getTripDuration(start: trip.start, end: trip.end)) days)")
                                                .font(.custom("Poppins-Regular", size: 12))
                                                .foregroundStyle(Color.gray)
                                        }
                                        
                                        if (getDaysUntilTrip(start: trip.start) <= 0) {
                                            Text("Happening Now")
                                                .font(.custom("Poppins-Bold", size: 12))
                                                .foregroundStyle(.darkTeal)
                                        } else {
                                            Text("\(getDaysUntilTrip(start: trip.start)) days until trip starts")
                                                .font(.custom("Poppins-Regular", size: 12))
                                        }
                                        
                                    }
                                    Image(systemName: "chevron.right")
                                        .padding(.trailing, 10)
                                        .foregroundStyle(.darkTeal)
                                }
                                .padding(15)
                                .padding(.leading, 15)
                            }
                            .padding(.bottom)
                            .background(Color.white)
                            .onTapGesture {
                                navigateToOverview = true
                            }
                            .navigationDestination(isPresented: $navigateToOverview) {
                                if let tripId = trip.id {
                                    TripView(tripId: tripId, isActive: getDaysUntilTrip(start: trip.start) <= 0)
                                        .navigationBarBackButtonHidden(true)
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

struct PastTripsView: View {
    @EnvironmentObject var myTripsViewModel: MyTripsViewModel
    @State private var navigateToOverview: Bool = false
    @State private var tripID: String = ""
    @State private var isActive: Bool = false
    @Binding var isTripsLoading: Bool
    
    var body: some View {
        VStack {
            if isTripsLoading {
                ProgressView()
                    .controlSize(.large)
            } else {
                Text("You had \(myTripsViewModel.pastTrips.count) past trips.")
                    .font(.custom("Poppins-Regular", size: 16))
                    .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .leading)
                    .padding()

                ScrollView {
                    ForEach(myTripsViewModel.pastTrips, id: \.id) { trip in
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.lighterGray)
                                .frame(width: UIScreen.main.bounds.width * 0.8, height:120)
                            HStack {
                                VStack (alignment: .leading) {
                                    Text(trip.name)
                                        .font(.custom("Poppins-Bold", size: 16))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundStyle(.darkTeal)
                                    Text("\(trip.city), \(trip.state)")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .padding(.bottom, 5)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    HStack {
                                        Text("\(getDateString(date: trip.start)) - \(getDateString(date: trip.end))")
                                            .font(.custom("Poppins-Regular", size: 12))
                                        
                                        Text("(\(getTripDuration(start: trip.start, end: trip.end)) days)")
                                            .font(.custom("Poppins-Regular", size: 12))
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.darkTeal)
                                    .padding(.trailing, 10)
                            }
                            .padding(15)
                            .padding(.leading, 15)
                        }
                        .padding(.bottom)
                        .background(Color.white)
                        .onTapGesture {
                            navigateToOverview = true
                        }
                        .navigationDestination(isPresented: $navigateToOverview) {
                            if let tripId = trip.id {
                                TripView(tripId: tripId, isActive: false)
                                    .navigationBarBackButtonHidden(true)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

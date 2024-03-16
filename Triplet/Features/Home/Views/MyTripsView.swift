//
//  MyTripsView.swift
//  Triplet
//
//  Created by Xiaolin Ma on 2/21/24.
//

import SwiftUI
import CoreLocation

struct MyTripsView: View {
    @State var tabSelection = 0
    @StateObject var myTripsViewModel: MyTripsViewModel = MyTripsViewModel()
    @State var tripCities: [String] = []
    @State var tripStates: [String] = []
    
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
            NavigationStack {
                if tabSelection == 0 {
                    CurrentTripsView()
                } else {
                    PastTripsView()
                }
            }
            .environmentObject(myTripsViewModel)

            Spacer()
        }
        .onAppear() {
            myTripsViewModel.subscribe()
        }
        .onDisappear {
            myTripsViewModel.unsubscribe()
        }
    }
}


struct NoTripPlanned: View {
    var body: some View {
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
            .frame(width: UIScreen.main.bounds.width * 0.8, height: 200)
        }
    }
}

func getDateString(date: Date?) -> String {
    guard let date else {
        return ""
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd"
    return dateFormatter.string(from: date)
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
    @State private var navigateToOverview: Bool = false
    @State private var tripID: String = ""
    @State private var isActive: Bool = false
    var body: some View {
        VStack {
            Text(" You have \(myTripsViewModel.currentTrips.count) trips planned.")
                .font(.custom("Poppins-Regular", size: 16))
                .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .leading)
                .padding()
            if myTripsViewModel.currentTrips.count == 0 {
                NoTripPlanned()
            }
            ScrollView {
                ForEach(0..<myTripsViewModel.currentTrips.count, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.lighterGray)
                            .frame(width: UIScreen.main.bounds.width * 0.8, height:120)
                        HStack {
                            VStack (alignment: .leading) {
                                Text(myTripsViewModel.currentTrips[index].name)
                                    .font(.custom("Poppins-Bold", size: 16))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.darkTeal)
                                Text("\(myTripsViewModel.currentTrips[index].city), \(myTripsViewModel.currentTrips[index].state)")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .padding(.bottom, 5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                HStack {
                                    Text("\(getDateString(date: myTripsViewModel.currentTrips[index].start)) - \(getDateString(date: myTripsViewModel.currentTrips[index].end))")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        
                                     Text("(\(getTripDuration(start: myTripsViewModel.currentTrips[index].start, end: myTripsViewModel.currentTrips[index].end)) days)")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundStyle(Color.gray)
                                }
                                
                                if (getDaysUntilTrip(start: myTripsViewModel.currentTrips[index].start) <= 0) {
                                    Text("Happening Now")
                                        .font(.custom("Poppins-Bold", size: 12))
                                        .foregroundStyle(.darkTeal)
                                } else {
                                    Text("\(getDaysUntilTrip(start: myTripsViewModel.currentTrips[index].start)) days until trip starts")
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
                        guard let tripID = myTripsViewModel.currentTrips[index].id else {
                            print("can't get tripID")
                            return
                        }
                        self.tripID = tripID
                        self.isActive = (getDaysUntilTrip(start: myTripsViewModel.currentTrips[index].start) <= 0)
                        print("tripID", self.tripID)
                        // navigate to overview page
                        navigateToOverview = true
                        
                    }
                    .navigationDestination(isPresented: $navigateToOverview) {
                        if self.tripID != "" {
                            NavigationStack {
                                TripView(tripId: self.tripID, isActive: $isActive)
                            }
                            .navigationBarBackButtonHidden(true)

                        }
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.85)
        }
    }
}

struct PastTripsView: View {
    @EnvironmentObject var myTripsViewModel: MyTripsViewModel
    @State private var navigateToOverview: Bool = false
    @State private var tripID: String = ""
    @State private var isActive: Bool = false
    var body: some View {
        VStack {
            
            Text("You had \(myTripsViewModel.pastTrips.count) past trips.")
                .font(.custom("Poppins-Regular", size: 16))
                .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .leading)
                .padding()
            if myTripsViewModel.pastTrips.count == 0 {
                NoTripPlanned()
            }
            
            
            ScrollView {
                ForEach(0..<myTripsViewModel.pastTrips.count, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.lighterGray)
                            .frame(width: UIScreen.main.bounds.width * 0.8, height:120)
                        HStack {
                            VStack (alignment: .leading) {
                                Text(myTripsViewModel.pastTrips[index].name)
                                    .font(.custom("Poppins-Bold", size: 16))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.darkTeal)
                                Text("\(myTripsViewModel.pastTrips[index].city), \(myTripsViewModel.pastTrips[index].state)")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .padding(.bottom, 5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                HStack {
                                    Text("\(getDateString(date: myTripsViewModel.pastTrips[index].start)) - \(getDateString(date: myTripsViewModel.pastTrips[index].end))")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        
                                     Text("(\(getTripDuration(start: myTripsViewModel.pastTrips[index].start, end: myTripsViewModel.pastTrips[index].end)) days)")
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
                        guard let tripID = myTripsViewModel.pastTrips[index].id else {
                            print("can't get tripID")
                            return
                        }
                        self.tripID = tripID
                        print("tripID", self.tripID)
                        // navigate to overview page
                        navigateToOverview = true
                    }
                    .navigationDestination(isPresented: $navigateToOverview) {
                        if self.tripID != "" {
                            NavigationStack {
                                TripView(tripId: self.tripID, isActive: $isActive)
                            }
                            .navigationBarBackButtonHidden(true)

                        }
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.85)
        }
        .padding(.bottom, 40)
    }
}
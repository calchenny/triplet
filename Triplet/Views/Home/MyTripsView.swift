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
    @EnvironmentObject var userModel: UserModel
    @EnvironmentObject var loginViewModel: LoginViewModel
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
            
            if tabSelection == 0 {
                NavigationStack {
                    CurrentTripsView()
                }
                .environmentObject(userModel)
            } else {
                PastTripsView()
                    .environmentObject(userModel)
            }
            Spacer()
        }
        .task {
            do {
                print("Loading user data")
                try await userModel.setUid(uid: loginViewModel.fetchUserUID())
    //                    userModel.subscribe()
                // Once user data is loaded, navigate to the home view
                await userModel.loadingUserData()
            } catch {
                print("No user data found")
            }
        }
        .onAppear() {
            print("trip of the user")
            print(userModel.trips.count)
            
        }
        .padding(40)
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
                    .foregroundColor(.lighterGray)
                    .font(.custom("Poppins-Bold", size: 24))
                Button {
                    
                } label: {
                    Text("Create a trip to get started")
                        .font(.custom("Poppins-Regular", size: 12))
                }
                .padding(15)
                .background(.darkTeal)
                .foregroundColor(.white)
                .cornerRadius(25)
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
    @EnvironmentObject var userModel: UserModel
    @State private var navigateToOverview: Bool = false
    @State private var tripID: String = ""
    @State private var isActive: Bool = false
    var body: some View {
        VStack {
            Text(" You have \(userModel.currentTrips.count) trips planned.")
                .font(.custom("Poppins-Regular", size: 16))
                .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .leading)
                .padding()
            if userModel.currentTrips.count == 0 {
                NoTripPlanned()
            }
            ScrollView {
                ForEach(0..<userModel.currentTrips.count, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.lighterGray)
                            .frame(width: UIScreen.main.bounds.width * 0.8, height:120)
                        HStack {
                            VStack (alignment: .leading) {
                                Text(userModel.currentTrips[index].name)
                                    .font(.custom("Poppins-Bold", size: 15))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.darkTeal)
                                Text("\(userModel.currentTrips[index].city), \(userModel.currentTrips[index].state)")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .padding(.bottom, 5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                HStack {
                                    Text("\(getDateString(date: userModel.currentTrips[index].start)) - \(getDateString(date: userModel.currentTrips[index].end))")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        
                                     Text("(\(getTripDuration(start: userModel.currentTrips[index].start, end: userModel.currentTrips[index].end)) days)")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundStyle(Color.gray)
                                }
                                
                                if (getDaysUntilTrip(start: userModel.currentTrips[index].start) == 0) {
                                    Text("Happening Now")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        .foregroundStyle(.darkTeal)
                                } else {
                                    Text("\(getDaysUntilTrip(start: userModel.currentTrips[index].start)) days until trip starts")
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
                        guard let tripID = userModel.currentTrips[index].id else {
                            print("can't get tripID")
                            return
                        }
                        self.tripID = tripID
                        self.isActive = (getDaysUntilTrip(start: userModel.currentTrips[index].start) == 0)
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
    @EnvironmentObject var userModel: UserModel
    @State private var navigateToOverview: Bool = false
    @State private var tripID: String = ""
    @State private var isActive: Bool = false
    var body: some View {
        VStack {
            
            Text("You had \(userModel.pastTrips.count) past trips.")
                .font(.custom("Poppins-Regular", size: 16))
                .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .leading)
                .padding()
            if userModel.pastTrips.count == 0 {
                NoTripPlanned()
            }
            
            
            ScrollView {
                ForEach(0..<userModel.pastTrips.count, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.lighterGray)
                            .frame(width: UIScreen.main.bounds.width * 0.8, height:120)
                        HStack {
                            VStack (alignment: .leading) {
                                Text(userModel.pastTrips[index].name)
                                    .font(.custom("Poppins-Bold", size: 15))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.darkTeal)
                                Text("\(userModel.pastTrips[index].city), \(userModel.pastTrips[index].state)")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .padding(.bottom, 5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                HStack {
                                    Text("\(getDateString(date: userModel.pastTrips[index].start)) - \(getDateString(date: userModel.pastTrips[index].end))")
                                        .font(.custom("Poppins-Regular", size: 12))
                                        
                                     Text("(\(getTripDuration(start: userModel.pastTrips[index].start, end: userModel.pastTrips[index].end)) days)")
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
                        guard let tripID = userModel.pastTrips[index].id else {
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

#Preview {
    MyTripsView()
        .environmentObject(UserModel())
        .environmentObject(LoginViewModel())
}

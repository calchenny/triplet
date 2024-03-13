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
                .frame(width: UIScreen.main.bounds.width * 0.30, alignment: .center)
            VStack(alignment: .leading) {
                Text("My Trips")
                    .font(.custom("Poppins-Medium", size: 20))
                Picker("", selection: $tabSelection) {
                    Text("Upcoming Trips")
                        .font(.custom("Poppins-Regular", size: 15))
                        .foregroundColor(.darkBlue)
                        .tag(0)
                        
                    Text("Past Trips")
                        .font(.custom("Poppins-Regular", size: 15))
                        .foregroundColor(.darkBlue)
                        .tag(1)
                        
                }
                .background(Color.evenLighterBlue)
                .pickerStyle(.segmented)
                .frame(width: UIScreen.main.bounds.width * 0.80)
            }
            
            if tabSelection == 0 {
                CurrentTripsView()
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
                    .foregroundColor(.darkBlue)
                    .font(.custom("Poppins-Bold", size: 22))
                Button {
                    
                } label: {
                    Text("Create a trip to get started")
                        .font(.custom("Poppins-Regular", size: 12))
                }
                .padding(15)
                .background(.darkBlue)
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


struct CurrentTripsView: View  {
    @EnvironmentObject var userModel: UserModel
    @State private var navigateToOverview: Bool = false
    @State private var currentTrips: [Trip] = []

    

    var body: some View {
        VStack {
            if userModel.currentTrips.count == 0 {
                NoTripPlanned()
            }
            Text(" You have \(userModel.currentTrips.count) trips planned.")
                .font(.custom("Poppins-Regular", size: 13))
                .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .leading)
                .padding()
            ScrollView {
                ForEach(0..<userModel.currentTrips.count, id: \.self) { index in

                    VStack (alignment: .leading) {
                        Text(userModel.currentTrips[index].name)
                            .font(.custom("Poppins-Bold", size: 12))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                        Text("\(userModel.currentTrips[index].city), \(userModel.currentTrips[index].state)")
                            .font(.custom("Poppins-Regular", size: 12))
                            .padding(.bottom, 5)
                            
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(getDateString(date: userModel.currentTrips[index].start)) - \(getDateString(date: userModel.currentTrips[index].end))")
                            .font(.custom("Poppins-Regular", size: 12))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(25)
                    .padding(.leading, 25)
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 120)
                    .background(Color.white)
                    .cornerRadius(20)
                    .opacity(1)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    )
                    .onTapGesture {
                        guard let tripID = userModel.currentTrips[index].id else {
                            print("can't get tripID")
                            return
                        }
                        print("tripID", tripID)
                        // navigate to overview page
                        navigateToOverview = true
                    }
                    .navigationDestination(isPresented: $navigateToOverview) {
//                            OverviewView()
//                                .environmentObject(userModel)
//                                .environmentObject(viewModel)
                    }
                    .padding(.bottom, 20)
                }
            }

        }
    }
}

struct PastTripsView: View {
//    @State var pastTrips: [String] = ["New York", "Seattle", "Big Sur"]
    @EnvironmentObject var userModel: UserModel
    


    var body: some View {
        VStack {
            if userModel.pastTrips.count == 0 {
                NoTripPlanned()
            }
            Text("You had \(userModel.pastTrips.count) past trips.")
                .font(.custom("Poppins-Regular", size: 13))
                .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .leading)
                .padding()
            ScrollView {
                ForEach(0..<userModel.pastTrips.count, id: \.self) { index in
                    HStack{
//                        Image(systemName: "bicycle")
//                            .resizable()
//                            .frame(width: 60, height: 60)
//                            .clipShape(Circle())
//                            .overlay(Circle().stroke(Color.black, lineWidth: 1))
//                        
//                        Spacer()
                        VStack (alignment: .leading) {
                            Text(userModel.pastTrips[index].name)
                                .font(.custom("Poppins-Bold", size: 12))
                            Text("\(userModel.pastTrips[index].city), \(userModel.pastTrips[index].state)")
                                .font(.custom("Poppins-Regular", size: 12))
                                .padding(.bottom, 5)
                            
                            Text("\(getDateString(date: userModel.pastTrips[index].start)) - \(getDateString(date: userModel.pastTrips[index].end))")
                                .font(.custom("Poppins-Regular", size: 12))
                        }
//                        .padding(10)
//                        .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                    }
                    .padding(35)
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 120)
                    .background(Color.white)
                    .cornerRadius(20)
                    .opacity(1)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                    )
                    .onTapGesture {
                        guard let tripID = userModel.pastTrips[index].id else {
                            print("can't get tripID")
                            return
                        }
                        print("tripID", tripID)
                    }
                    .padding(.bottom, 20)
                    }
                }

        }
        .padding(.bottom, 40)
    }
}

#Preview {
    MyTripsView()
}

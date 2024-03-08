//
//  MyTripsView.swift
//  Triplet
//
//  Created by Xiaolin Ma on 2/21/24.
//

import SwiftUI

struct MyTripsView: View {
    @State var tabSelection = 0
    @EnvironmentObject var userModel: UserModel
    @EnvironmentObject var loginViewModel: LoginViewModel
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
                CurrentTripsView(trips: userModel.trips)
            } else {
                PastTripsView()
            }
            Spacer()
        }
        .task {
            if userModel.trips.isEmpty {
                do {
                    print("Loading user data")
                    try await userModel.setUid(uid: loginViewModel.fetchUserUID())
                    userModel.subscribe()
                    // Once user data is loaded, navigate to the home view
                    await userModel.loadingUserData()
                } catch {
                    print("No user data found")
                }
            }
        }
        .onAppear() {
            print("trip of the user")
            print(userModel.trips)
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

struct CurrentTripsView: View  {
    @State var currentTrips: [String] = ["New York, NY", "Seattle, WA", "Big Sur"]
    @State var trips: [Trip]
    @State var tripNames: [String] = ["Concrete Jungle", "Space Needle Here We Go", "Big Sir"]
    @State var tripDates: [String] = ["11/10/24 - 11/20/24", "11/20/24 - 11/25/24", "12/10/24 - 12/20/24"]
    var body: some View {
        VStack {
            if trips.count == 0 {
                NoTripPlanned()
            }
            ForEach(0..<trips.count, id: \.self) { index in
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 120)
                        .shadow(color: .black, radius:2, x: 0, y: 3)  // << no offset by x
                    HStack{
                        Image(systemName: "bicycle")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.black, lineWidth: 1))
                            
                        Spacer()
                        VStack (alignment: .leading) {
                            Text(trips[index].name)
                                .font(.custom("Poppins-Bold", size: 12))
                            Text("destination")
                                .font(.custom("Poppins-Regular", size: 12))
                                .padding(.bottom, 5)
//                            Text(trips[index].numGuests)
//                                .font(.custom("Poppins-Regular", size: 12))
                        }
                        .padding(10)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.60)
                        Button{
                            
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .padding(10)
                                .background(Color("Dark Blue"))
                                .foregroundStyle(.white)
                                .clipShape(Circle())
                        }
                        
                    }
                    .padding(35)
                    .frame(width: UIScreen.main.bounds.width * 0.8, height: 120)
                    .background(Color.white)
                    .cornerRadius(20)
                    .opacity(1)
                }
                .padding(.bottom, 20)
                

            }

        }
    }
}

struct PastTripsView: View {
//    @State var pastTrips: [String] = ["New York", "Seattle", "Big Sur"]
    @State var pastTrips: [String] = []
    @State var tripDates: [String] = ["11/10/24 - 11/20/24", "11/20/24 - 11/25/24", "12/10/24 - 12/20/24"]
    var body: some View {
        VStack {
            if pastTrips.count == 0 {
                NoTripPlanned()
            }
            ForEach(0..<pastTrips.count, id: \.self) { index in
                HStack{
                    Image(systemName: "bicycle")
                    VStack (alignment: .leading) {
                        Text("Trip to \(self.pastTrips[index])")
                        Text("Dates: \(self.pastTrips[index])")
                    }
                    .padding(20)
                }
                
            }
        }
        .padding(.bottom, 40)
        .padding(.top, 40)
    }
}

#Preview {
    MyTripsView()
}

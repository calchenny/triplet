//
//  MyTripsView.swift
//  Triplet
//
//  Created by Xiaolin Ma on 2/21/24.
//

import SwiftUI

struct MyTripsView: View {
    @State var tabSelection = 0

    var body: some View {
        VStack(alignment: .leading){
            Text("My Trips")
            Picker("", selection: $tabSelection) {
                Text("Current Trips")
                    .tag(0)
                Text("Past Trips")
                    .tag(1)
            }
            .pickerStyle(.segmented)
            if tabSelection == 0 {
                CurrentTripsView()
            } else {
                PastTripsView()
            }
            Spacer()
        }
        .padding(40)
    }
}


struct NoTripPlanned: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.2))
                .frame(width: UIScreen.main.bounds.width * 0.8, height: 200)
            VStack {
                Text("No trip planned")
                    .padding(.bottom, 20)
                Button {
                    
                } label: {
                    Text("Create a trip to get started")
                }
                .padding(15)
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(25)
            }
            .padding(25)
            .frame(width: UIScreen.main.bounds.width * 0.8, height: 200)
        }
    }
}

struct CurrentTripsView: View {
    @State var currentTrips: [String] = ["New York", "Seattle", "Big Sur"]
//    @State var currentTrips: [String] = []
    @State var tripNames: [String] = ["Concrete Jungle", "Space Needle Here We Go", "Big Sir"]
    @State var tripDates: [String] = ["11/10/24 - 11/20/24", "11/20/24 - 11/25/24", "12/10/24 - 12/20/24"]
    var body: some View {
        VStack {
            if currentTrips.count == 0 {
                NoTripPlanned()
            }
            ForEach(0..<currentTrips.count, id: \.self) { index in
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
                            Text("Trip to \(self.currentTrips[index])")
                            Text(self.tripDates[index])
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.45)
                        ZStack{
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 35, height: 35)
                            Button{
                                
                            } label: {
                                Text(">")
                            }
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

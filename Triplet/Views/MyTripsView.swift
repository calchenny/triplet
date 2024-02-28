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


struct CurrentTripsView: View {
    @State var currentTrips: [String] = ["New York", "Seattle", "Big Sur"]
//    @State var currentTrips: [String] = []
    @State var tripNames: [String] = ["Concrete Jungle", "Space Needle Here We Go", "Big Sir"]
    @State var tripDates: [String] = ["11/10/24 - 11/20/24", "11/20/24 - 11/25/24", "12/10/24 - 12/20/24"]
    var body: some View {
        VStack {
            if currentTrips.count == 0 {
                Text("You have no past trips yet. Go on some adventures today! :)")
                
            }
            ForEach(0..<currentTrips.count, id: \.self) { index in
                HStack{
                    Image(systemName: "bicycle")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(Rectangle())
                        .overlay(Rectangle().stroke(Color.white, lineWidth: 3))
                        .border(Color.black)
                    Spacer()
                    VStack (alignment: .leading) {
                        Text(self.tripNames[index])
                            .bold()
                        Text("Trip to \(self.currentTrips[index])")
                            .padding(.bottom, 20)
                        Text(self.tripDates[index])
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.5)
                }
                .frame(width: UIScreen.main.bounds.width * 0.7)
                .padding(.bottom, 40)
                .padding(.top, 40)
                Divider()
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
                Text("You have no past trips yet. Go on some adventures today! :)")
                    .padding(.bottom, 20)
                Button {
                    
                } label: {
                    Text("Plan your dream trip today!")
                }
                .padding()
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(24)
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

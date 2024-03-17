//
//  NewTripView.swift
//  Triplet
//
//  Created by Calvin Chen on 2/20/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct NewTripView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var destinationViewModel = DestinationViewModel()
    @State var tripId: String?
    @State var guests: Int = 0
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var tripName: String = ""
    @State var showDestinationSheet: Bool = false
    @State var isActive: Bool = false
    @Binding var selectedIndex: Int
    
    func createTrip() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Missing user")
            return
        }
        
        print("Hit")
        guard let latitude = destinationViewModel.latitude,
              let longitude = destinationViewModel.longitude,
              let city = destinationViewModel.city,
              let state = destinationViewModel.state,
              let start = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: startDate),
              let end = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) else {
                return
        }

        let trip = Trip(owner: uid,
                        name: tripName,
                        start: start,
                        end: end,
                        destination: GeoPoint(latitude: latitude, longitude: longitude),
                        numGuests: guests,
                        city: city,
                        state: state)

        do {
            let ref = try Firestore.firestore().collection("trips").addDocument(from: trip)
            print("Added to Firestore")
            print("Trip ID: ", ref.documentID)
            tripId = ref.documentID
            selectedIndex = 0
        } catch {
            print("Error: ", error)
        }

        print("Created Trip: \(trip)")
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("Plan New Trip")
                    .font(.custom("Poppins-Bold", size: 30))
                    .foregroundStyle(Color("Dark Teal"))
                    .padding(.bottom, 5)
                
                Text("Build an itinerary and map out your upcoming travel plans")
                    .font(.custom("Poppins-Regular", size: 14))
                    .frame(maxWidth: UIScreen.main.bounds.width/1.5, alignment: .center)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical:true)
            }
            .padding()

            Text("Where to?")
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundStyle(Color("Dark Teal"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            
            if let city = destinationViewModel.city {
                // Store city into user model
                if let state = destinationViewModel.state {
                    // Store state into user model
                    Text("\(city), \(state)")
                        .font(.custom("Poppins-Regular", size: 16))
                        .frame(maxWidth: 270, alignment: .leading)
                        .padding(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.gray)
                        )
                        .padding(.top, 10)
                        .onTapGesture {
                            showDestinationSheet.toggle()
                        }
                        .sheet(isPresented: $showDestinationSheet) {
                            DestinationSearchView(locationSearch: LocationSearch())
                                .environmentObject(destinationViewModel)
                        }
                }
                
            } else {
                Text("e.g, Davis, New York, Seattle")
                    .font(.custom("Poppins-Regular", size: 16))
                    .frame(maxWidth: 270, alignment: .leading)
                    .foregroundStyle(.placeholder)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray)
                    )
                    .padding(.top, 10)
                    .onTapGesture {
                        showDestinationSheet.toggle()
                    }
                    .sheet(isPresented: $showDestinationSheet) {
                        DestinationSearchView(locationSearch: LocationSearch())
                            .environmentObject(destinationViewModel)
                            .presentationDragIndicator(.visible)
                            .presentationCornerRadius(25)
                    }
                
            }
            
            Text("Dates")
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundStyle(Color("Dark Teal"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            
            HStack {
                Image(systemName: "calendar")
                
                if (startDate ==  Date.distantPast) {
                    Text("Start Date")
                        .font(.custom("Poppins-Regular", size: 16))
                        .frame(width: 150)
                        .foregroundStyle(.placeholder)
                } else {
                    Text(startDate, style: .date)
                        .font(.custom("Poppins-Regular", size: 16))
                        .frame(width: 150)

                }
                
            }
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray)
            )
            .padding(.horizontal, 10)
            .overlay{
                DatePicker("",selection: $startDate, in: Date.now..., displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .blendMode(.destinationOver)
                    .padding(.horizontal, 10)
                    .tint(.darkTeal)
            }
            
            HStack {
                Image(systemName: "calendar")
                if (endDate ==  Date.distantPast || startDate > endDate) {
                    Text("End Date")
                        .font(.custom("Poppins-Regular", size: 16))
                        .frame(width: 150)
                        .foregroundStyle(.placeholder)
                } else{
                    Text(endDate, style: .date)
                        .font(.custom("Poppins-Regular", size: 16))
                        .frame(width: 150)

                }
            }
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray)
            )
            .padding(.horizontal, 10)
            .padding(.top, 10)
            .overlay{
                DatePicker("",selection: $endDate, in: startDate..., displayedComponents: .date)
                    .disabled(startDate ==  Date.distantPast)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .blendMode(.destinationOver)
                    .padding(.horizontal, 10)
                    .tint(.darkTeal)
            }
            
            HStack {
                VStack {
                    Text("How many guests?")
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundStyle(Color("Dark Teal"))
                        .padding(.trailing)
                    Text("(Including yourself)")
                        .font(.custom("Poppins-Regular", size: 11))
                        .foregroundStyle(.darkerGray)
                        .padding(.trailing)
                }
                
                Stepper {
                    Text("\(guests)")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundStyle(.black)
                    
                } onIncrement: {
                    if (guests < 20) {
                        guests += 1
                    }
                } onDecrement: {
                    if (guests <= 1) {
                        guests = 0
                    } else {
                        guests -= 1

                    }
                }
                .padding(.leading, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray)
                )
                .padding(.top, 10)

            }
            .padding(.top)

            Text("Trip Name")
                .font(.custom("Poppins-Bold", size: 16))
                .foregroundStyle(Color("Dark Teal"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            
            TextField("e.g, Most Amazing Trip Ever", text: $tripName)
                .onChange(of: tripName) {
                    if (tripName.count > 30) {
                        tripName = String(tripName.prefix(30))
                    }
                }
                .font(.custom("Poppins-Regular", size: 16))
                .keyboardType(.alphabet)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            tripName == "" ?
                            Color(.gray) : Color(.green)
                        )
                )
                .padding(.horizontal, 20)

            Button {
                createTrip()
            } label: {
                Text("Start Planning")
                    .font(.custom("Poppins-Bold", size: 16))
                    .padding(5)
                    .frame(width: UIScreen.main.bounds.width/1.5, alignment: .center)
            }
            .cornerRadius(15)
            .buttonStyle(.borderedProminent)
            .padding(.vertical)
            .tint(.darkTeal)
        }
    }
}

//#Preview {
//    NewTripView()
//}

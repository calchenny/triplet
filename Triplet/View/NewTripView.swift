//
//  NewTripView.swift
//  Triplet
//
//  Created by Calvin Chen on 2/20/24.
//

import SwiftUI

struct NewTripView: View {
    @Binding var destination: String
    @State var guests: Int = 0
    @State var showsDatePicker = false
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var tripName: String = ""
    @State var showDestinationSheet: Bool = false

    @State var date: Date = Date()
    
    @State private var hiddenDate: Date = Date()
    @State private var showDate: Bool = false
    
    func startPlan() {
        print("submit planning data")
    }
    
    var body: some View {
        VStack {
            Text("Plan a new trip")
                .font(.title)
                .fontWeight(.heavy)
            
            Text("Build an itinerary and map out your upcoming travel plans")
                .font(.headline)
                .frame(maxWidth: UIScreen.main.bounds.width/1.5, alignment: .leading)
                .multilineTextAlignment(.center)
                .padding(.vertical)

            Text("Where to?")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            
            TextField("e.g, New York, Japan, Sacramento", text: $destination)
                .keyboardType(.alphabet)
                .padding(8)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray)
                )
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .onTapGesture {
                    showDestinationSheet.toggle()
                }
                .sheet(isPresented: $showDestinationSheet, onDismiss: {
                    destination = destination
                }) {
                    DestinationSearchView(locationService: LocationService(), destination: $destination)
                }
            
            Text("Dates (optional)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            
//            if showDate {
//                DatePicker(
//                    "",
//                    selection: $hiddenDate,
//                    in: Date.now...,
//                    displayedComponents: .date
//                )
//                .labelsHidden()
//                .onChange(of: hiddenDate) {
//                    startDate = hiddenDate
//                }
//
//            } else {
//                Button {
//                    showDate = true
//                    startDate = hiddenDate
//                } label: {
//                    Image(systemName: "calendar")
//                        .foregroundColor(.gray)
//                    Text("Start Date")
//                        .multilineTextAlignment(.center)
//                        .foregroundColor(.black)
//                }
//                .frame(width: 120, height: 34)
//                .background(
//                    RoundedRectangle(cornerRadius: 8)
//                        .fill(.placeholder)
//                )
//                .multilineTextAlignment(.trailing)
//                
//            }
            
            HStack {
                DatePicker("",selection: $startDate, in: Date.now..., displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .padding(8)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray)
                )
                .padding(.horizontal, 10)
                .background(.white)
                
                DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding(8)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray)
                    )
                    .padding(.horizontal, 10)
            }
            
            HStack {
                Text("How many people are going?")
                    .font(.headline)

                Stepper {
                    if (guests == 0) {
                        Text("e.g, 3 or 5")
                            .foregroundStyle(.placeholder)
                    } else {
                        Text("\(guests)")
                            .foregroundStyle(.black)

                    }
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
                .padding(8)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray)
                )
                .padding(.top, 10)
                
            }
            .padding(.top)

            
            Text("Trip Name")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)

            
            TextField("e.g, Most Amazing Trip Ever", text: $tripName)
                .keyboardType(.alphabet)
                .padding(8)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray)
                )
                .padding(.horizontal, 20)
                .padding(.top, 10)

            Button(action: startPlan) {
                Text("Start Planning")
                    .fontWeight(.heavy)
                    .padding(5)
                    .frame(width: UIScreen.main.bounds.width/1.5, alignment: .center)
            }
            .cornerRadius(15)
            .buttonStyle(.borderedProminent)
            .padding(.vertical)
            .tint(.gray)

        }
        .padding()

    }
}

#Preview {
    NewTripView(destination: .constant(""))
}

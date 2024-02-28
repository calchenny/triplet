//
//  NewTripView.swift
//  Triplet
//
//  Created by Calvin Chen on 2/20/24.
//

import SwiftUI

struct NewTripView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var destinationViewModel = DestinationViewModel()
    @State var guests: Int = 0
    @State var startDate: Date = Date.distantPast
    @State var endDate: Date = Date.distantPast
    @State var tripName: String = ""
    @State var showDestinationSheet: Bool = false
    
    func startPlan() {
        print("submit data")
        print(startDate)
        print(endDate)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "arrowshape.backward.fill")
                        .font(.headline)
                        .padding(12)
                        .background(.gray)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 4, x: 0, y: 4)
                })
                Spacer()
            }
            .padding(5)
            
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
            
            if let city = destinationViewModel.city {
                if let state = destinationViewModel.state {
                    Text("\(city), \(state)")
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
                    }
                
            }
            
            Text("Dates (optional)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            
            HStack {
                Image(systemName: "calendar")
                
                if (startDate ==  Date.distantPast) {
                    Text("Start Date")
                        .frame(width: 150)
                        .foregroundStyle(.placeholder)
                } else {
                    Text(startDate, style: .date)
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
                DatePicker("",selection: $startDate, in: Date.now..., displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .blendMode(.destinationOver)
                    .padding(.horizontal, 10)
            }
            
            HStack {
                Image(systemName: "calendar")
                if (endDate ==  Date.distantPast || startDate > endDate) {
                    Text("End Date")
                        .frame(width: 150)
                        .foregroundStyle(.placeholder)
                } else{
                    Text(endDate, style: .date)
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
            }
                
            
            HStack {
                VStack {
                    Text("How many guests?")
                        .font(.headline)
                        .padding(.trailing)
                    Text("(Including yourself)")
                        .font(.caption)
                        .foregroundStyle(.placeholder)
                        .padding(.trailing)
                }

                Stepper {
                    Text("\(guests)")
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
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)

            
            TextField("e.g, Most Amazing Trip Ever", text: $tripName)
                .onChange(of: tripName) {
                    if (tripName.count > 30) {
                        tripName = String(tripName.prefix(30))
                    }
                }
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
    NewTripView()
        .environmentObject(DestinationViewModel())
}

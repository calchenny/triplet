//
//  ItineraryView.swift
//  Triplet
//
//  Created by Andy Lam on 2/20/24.
//



import SwiftUI
import EventKit

//struct Event: Identifiable {
//    let id = UUID()
//    let name: String
//    let location: String
//}


struct ItineraryView: View {
    
    // test events --> will load from database in future
//    let events = [
//        Event(name: "Tim's Kitchen", location: "123 Main St"),
//        Event(name: "Fancy Shopping Mall", location: "453 Second St"),
//        Event(name: "Music Concert", location: "City Arena"),
//        Event(name: "UC Davis", location: "Davis")
//    ]
    
    @StateObject var itineraryModel = ItineraryViewModel()
    @State var searchText: String = ""
    
    @State var showAddEventSheet: Bool = false
    
    var body: some View {
        VStack {
            Text("**Most Amazing Trip**\n10/20 - 10/25")
                .padding()
                .multilineTextAlignment(.center)
                .foregroundColor(.indigo)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.indigo, lineWidth: 4)
                }
                .padding()
            
            HStack {
                // Contains the date buttons
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 10) {
                        ForEach(["10/20", "10/21", "10/22", "10/23", "10/24", "10/25"], id: \.self) { day in
                            Button(action: {
                                // Handle button action for each day
                            }) {
                                Text(day)
                                    .foregroundColor(.indigo)
                                    .frame(minWidth: 60, minHeight: 40)
                            }
                            .padding(.horizontal, 5)
                        }
                    }
                }
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
                
                Spacer() // Pushes everything to the left and the button to the right
                
                Button(action: {
                    // Handle edit button action
                }) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.indigo)
                }
                .frame(minWidth: 40, minHeight: 40)
            }
            .padding()
            
//            if itineraryModel.events.isEmpty {
//                Text("No events planned yet!")
//                    .font(.headline)
//                    .foregroundColor(.gray)
//                    .padding()
//            } else {
//                ScrollView {
//                    ForEach(itineraryModel.events) { event in
//                        VStack {
//                            Text(event.name)
//                                .font(.headline)
//                            Text(event.location)
//                                .font(.subheadline)
//                        }
//                        .padding()
//                        .background(Color.gray.opacity(0.2))
//                        .cornerRadius(10)
//                        .padding(.vertical, 5)
//                    }
//                }
//            }
            Button(action: {
                showAddEventSheet.toggle()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Add a Place/Event")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.indigo)
                .cornerRadius(10)
            }
            .padding(.top, 20)
            .sheet(isPresented: $showAddEventSheet) {
                AddPlaceView()
                    .environmentObject(itineraryModel)
            }

            Spacer()
        }
    }
}


#Preview {
    ItineraryView()
}

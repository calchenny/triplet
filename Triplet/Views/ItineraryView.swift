//
//  ItineraryView.swift
//  Triplet
//
//  Created by Andy Lam on 2/20/24.
//



import SwiftUI
import EventKit


func getCategoryImageName(category: String) -> String {

    switch category {
    case "Restaurant":
        return "fork.knife.circle"
    case "Attraction":
        return "star"
    case "Hotel":
        return "house"
    case "Transit":
        return "bus"
    default:
        return "questionmark"
    }
}

func formatDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd" // Customize the format as needed
    return dateFormatter.string(from: date)
}

func formatTime(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mm a" // Customize the format as needed
    return dateFormatter.string(from: date)
}



struct ItineraryView: View {
    
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
            }
            .padding()
            Button(action: {
                showAddEventSheet.toggle()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("Add an Event")
                        .font(.subheadline)
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.indigo)
                .cornerRadius(10)
            }
            .padding(.bottom, 5)
            .sheet(isPresented: $showAddEventSheet) {
                AddPlaceView()
                    .environmentObject(itineraryModel)
            }
            
            if itineraryModel.events.isEmpty {
                Text("No events planned yet!")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    ForEach(["10/20", "10/21", "10/22", "10/23", "10/24", "10/25"], id: \.self) { day in
                        
                        HStack {
                            Spacer()
                            Text(day)
                                .font(.title)
                                .foregroundStyle(Color.indigo)
                            Spacer()
                        }
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                        .frame(maxWidth: .infinity)
                        VStack {
                            ForEach(itineraryModel.events.filter { formatDate($0.date) == day }.sorted { $0.time < $1.time }) { event in
                                HStack(spacing: 10) {
                                    // Image for the event's category
                                    Image(systemName: getCategoryImageName(category: event.category))
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.indigo)
                                    
                                    Divider()
                                        .frame(width: 2)
                                        .background(Color.indigo)
                                    
                                    // Event details
                                    VStack(alignment: .leading) {
                                        Text(event.name)
                                            .font(.headline)
                                        Text(formatTime(event.time))
                                            .font(.subheadline)
                                        Text(event.location)
                                            .font(.subheadline)
                                    }
                                    .padding()
                                    Spacer()
                                    
                                    Button(action: {
                                        // Handle menu button action
                                    }) {
                                        Image(systemName: "line.3.horizontal")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.indigo)
                                    }
                                }
                                .padding(20)
                            }
                        }
                        .padding(.bottom, 10)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            Spacer()
        }
    }
}



#Preview {
    ItineraryView()
}

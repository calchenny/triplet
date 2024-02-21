//
//  ItineraryView.swift
//  Triplet
//
//  Created by Andy Lam on 2/20/24.
//

import SwiftUI

struct Event: Identifiable {
    let id = UUID()
    let name: String
    let location: String
}


struct ItineraryView: View {
    
    // test events --> will load from database in future
    let events = [
        Event(name: "Tim's Kitchen", location: "123 Main St"),
        Event(name: "Fancy Shopping Mall", location: "453 Second St"),
        Event(name: "Music Concert", location: "City Arena"),
        Event(name: "UC Davis", location: "Davis")
    ]
    
    @State var searchText: String = ""

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

            // Handle infinite scroll of the calendar
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(["10/20", "10/21", "10/22", "10/23", "10/24", "10/25"], id: \.self) { day in
                        
                        HStack {
                            Text("\(day)")
                                .foregroundColor(.indigo)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                        }
                        .background(Color.indigo.opacity(0.2))
                        .cornerRadius(10)
                        .padding(10)
                        
                        // Search Bar moved to be near top of events
                        HStack{
                            TextField("Search events", text: $searchText)
                                .foregroundColor(.indigo)
                                .frame(height: 40)
                                .cornerRadius(10)
                                .padding(.horizontal, 10)
                            
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.indigo, lineWidth: 2)
                        )
                        .padding(.top, 10)
                        .padding(.horizontal, 10)
                        
                        ZStack(alignment: .leading) {
                            // Vertical line
                            Rectangle()
                                .fill(Color.indigo)
                                .frame(width: 4)
                                .padding(.leading, 75)
                                .frame(maxHeight: .infinity)
                            
                            VStack {
                                ForEach(events) { event in
                                    HStack(spacing: 40) { // spacing here to separate picture from text
                                        ZStack {
                                            Circle() // Circle allows us to have the picture over line effect
                                                .fill(Color.white)
                                                .frame(width: 60, height: 60)
                                                .overlay(
                                                    Image(systemName: "calendar")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 50, height: 50)
                                                )
                                        }
                                        .background(Color.indigo) // This is to create the 'overlay' effect
                                        .clipShape(Circle()) // Ensures the overlay effect is circular
                                        .offset(x: -2, y: 0) // adjusts x and y axis to align picture over the line
                                        
                                        // Handles the event description
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(event.name)
                                                .font(.headline)
                                            Text("Location: \(event.location)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 30)
                                    .padding(.leading, 50)
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            Spacer()
        }
    }
}


#Preview {
    ItineraryView()
}

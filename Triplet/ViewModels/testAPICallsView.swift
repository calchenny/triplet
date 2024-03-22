//
//  testAPICallsView.swift
//  Triplet
//
//  Created by Newland Luu on 3/14/24.
//

import SwiftUI

struct testAPICallsView: View {
    @State private var aliases: [String] = []
    @State private var photoURLs: [String] = []
    @State private var names: [String] = []
    @State private var yelpURLs: [String] = []
    
    //instantiate apiCaller object to make calls to API functions
    @StateObject var apiCaller = APICaller()

    //yelp API parameters
    @State var eventName: String
    @State var longitude: Double
    @State var latitude: Double
    @State var term: String

    var body: some View {
        VStack(alignment: .center) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Plan gone wrong?")
                        .font(.custom("Poppins-Medium", size: 16))
                    Text("Here's some similar locations: ")
                        .font(.custom("Poppins-Regular", size: 12))
                }
                Spacer()
            }
            .padding(.bottom)
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 10) {
                    if photoURLs.count != 0 {
                        ForEach(photoURLs.indices, id: \.self) { index in
                            VStack {
                                AsyncImage(url: URL(string: photoURLs[index])) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 100, height: 100)
                                .onTapGesture{
                                    if let url = URL(string: yelpURLs[index]), UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                .cornerRadius(15)
                                Text(names[index])
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: 100, alignment: .center)
                                    .font(.custom("Poppins-Regular", size: 14))
                            }
                            .frame(width: 100)
                        }
                    }
                }
            }
        }
        .padding()
        .padding(.bottom, 5)
        .onAppear {
            print("appeared")
            //make API call when the view appears
            apiCaller.yelpRetrieveVenues(eventName: eventName, longitude: longitude, latitude: latitude, term: term) { (aliases, error) in
                
                if let aliases = aliases {
                    self.aliases = aliases
                    print("Aliases: \(aliases)")
                    
                    // Call loadSuggestions inside the completion handler
                    for alias in aliases {
                        let currentAlias = alias // Create a local copy

                        //yelpLoadSuggestions() returns a tuple, (name, photoURL, yelpURL)
                        //make second API call using the specifc business aliases returned from yelpRetrieveVenues()
                        apiCaller.yelpLoadSuggestions(alias: currentAlias) { (result, error) in
                            if let result = result {
                                DispatchQueue.main.async {
                                    for tuple in result {
                                        self.names.append(tuple.0)
                                        self.photoURLs.append(tuple.1)
                                        self.yelpURLs.append(tuple.2)
                                    }
                                }
                            } else if let error = error {
                                print("Error: \(error)")
                            }
                        }
                    }
                } else if let error = error {
                    print("Error: \(error)")
                }
            }
        }
    }
}

//#Preview {
//    testAPICallsView(eventName: "T4", longitude: -121.7405, latitude: 38.5449, term: "boba")
//}

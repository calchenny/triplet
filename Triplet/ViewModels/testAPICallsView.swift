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
    @StateObject var apiCaller = APICaller()

    //local testing variables
    @State var longitude: Double
    @State var latitude: Double
    @State var term: String
    @State private var address: String = "1%20Shields%20Ave%2C%20Davis%2C%20CA%2095616"

    var body: some View {
        VStack {
            
            HStack {
                Text("Plan gone wrong? \nHere's some similar locations: ")
                    .font(.custom("Poppins-Regular", size: 16))
                .foregroundStyle(Color.darkTeal)
                Spacer()
            }
            //.padding(.leading, 50)
                
                
            HStack {
                if photoURLs.count != 0 {
                    ForEach(photoURLs.prefix(3).indices, id: \.self) { index in
                        let imageURL = photoURLs[index]
                        let name = names[index]

                        VStack {
                            VStack {
                                AsyncImage(url: URL(string: imageURL), content: { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 125, maxHeight: 125)
                                        //.clipShape(Circle())
                                }, placeholder: {ProgressView()})
                            }
                            .frame(width: 100)
                            .cornerRadius(50)
                            Text(name)
                                .font(.custom("Poppins-Regular", size: 12))
                                .foregroundStyle(Color.darkTeal)
                        }
                    }
                }
            }
            .padding(50)
            
        }
        .onAppear {
            print("appeared")
            apiCaller.yelpRetrieveVenues(longitude: longitude, latitude: latitude, term: term) { (aliases, error) in
                if let aliases = aliases {
                    self.aliases = aliases
                    print("Aliases: \(aliases)")
                    
                    // Call loadSuggestions inside the completion handler
                    for alias in aliases {
                        let currentAlias = alias // Create a local copy

                        apiCaller.yelpLoadSuggestions(alias: currentAlias) { (result, error) in
                            if let result = result {
                                DispatchQueue.main.async {
                                    for tuple in result {
                                        self.names.append(tuple.0)
                                        self.photoURLs.append(tuple.1)
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

//        VStack {
//            Button {
//                apiCaller.getWalkScore(latitude: latitude, longitude: longitude, address: address) { (walkscore, description, error) in
//                    if let error = error {
//                        print("Error: \(error)")
//                        // Handle error case here
//                    } else if let walkscore = walkscore, let description = description {
//                        print("Walk Score: \(walkscore)")
//                        print("Description: \(description)")
//                        // Use walkscore and description here
//                    }
//                }
//            } label: {
//                Text("Test walkScore()")
//            }
//            Button {
//                apiCaller.getWalkScore2()
//            } label: {
//                Text("Test walkScore2()")
//            }
//            Button {
//                apiCaller.yelpRetrieveVenues(longitude: longitude, latitude: latitude, term: term) { (aliases, error) in
//                    if let aliases = aliases {
//                        self.aliases = aliases
//                        print("Aliases: \(aliases)")
//                    } else if let error = error {
//                        print("Error: \(error)")
//                    }
//                }
//            } label: {
//                Text("Test retriveVenues()")
//            }
//
//            Button {
//                let dispatchGroup = DispatchGroup()
//
//                for alias in aliases {
//                    let currentAlias = alias // Create a local copy
//
//                    dispatchGroup.enter()
//
//                    apiCaller.yelpLoadSuggestions(alias: currentAlias) { (result, error) in
//                        defer {
//                            dispatchGroup.leave()
//                        }
//
//                        if let result = result {
//                                DispatchQueue.main.async {
//                                    for tuple in result {
//                                        self.names.append(tuple.0)
//                                        self.photoURLs.append(tuple.1)
//                                    }
//                                }
//
//                        } else if let error = error {
//                            print("Error: \(error)")
//                        }
//                    }
//                }
//
//                dispatchGroup.notify(queue: .main) {
//                    // This will be called once all loadSuggestions tasks are complete
//                    print("Names: \(self.names)")
//                    print("PhotoURLs: \(self.photoURLs)")
//                }
//            } label: {
//                Text("Test loadSuggestions()")
//            }
//            Spacer()
//            HStack {
//                if photoURLs.count != 0 {
//                    ForEach(photoURLs.prefix(3).indices, id: \.self) { index in
//                        let imageURL = photoURLs[index]
//                        let name = names[index]
//
//                        VStack {
//                            AsyncImage(url: URL(string: imageURL), content: { image in
//                                image.resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(maxWidth: 125, maxHeight: 125)
//                                    //.clipShape(Circle())
//                            }, placeholder: {ProgressView()})
//                            Text(name)
//                                .multilineTextAlignment(.center)
//                                .font(.caption)
//                        }
//                    }
//                }
//            }
//
//
//        }
    }
}

#Preview {
    testAPICallsView(longitude: -121.7405, latitude: 38.5449, term: "boba")
}

//
//  DestinationSearchView.swift
//  Triplet
//
//  Created by Calvin Chen on 2/20/24.
//

import SwiftUI
import MapKit

struct DestinationSearchView: View {
    @ObservedObject var locationService: LocationService

    func selectedDestination() {
        print("Selected place")
    }
    
    var body: some View {
        VStack {
                Form {
                    Section(header: Text("Location Search")) {
                        ZStack(alignment: .trailing) {
                            TextField("Search", text: $locationService.queryFragment)
                            // Displays an icon during an active search
                            if locationService.status == .isSearching {
                                Image(systemName: "clock")
                                    .foregroundColor(Color.gray)
                            }
                        }
                    }
                    Section(header: Text("Results")) {
                        List {
                            Group { () -> AnyView in
                                switch locationService.status {
                                case .noResults: return AnyView(Text("No Results"))
                                case .error(let description): return AnyView(Text("Error: \(description)"))
                                default: return AnyView(EmptyView())
                                }
                            }.foregroundColor(Color.gray)

                            ForEach(locationService.searchResults, id: \.self) { completionResult in
                                // This simply lists the results, use a button in case you'd like to perform an action
                                // or use a NavigationLink to move to the next view upon selection.
                                Button(action: selectedDestination) {
                                    HStack {
                                        Text(completionResult.title)
                                            .foregroundStyle(.black)
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
}

#Preview {
    DestinationSearchView(locationService: LocationService())
}

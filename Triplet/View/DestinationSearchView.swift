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
    @Binding var destination: String
    @Environment(\.dismiss) var dismiss
    
    func selectedDestination(completion: MKLocalSearchCompletion) {
        print("Selected place: \(completion.title)")
        
        // Store into model eventually
        destination = completion.title
        
        dismiss()
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "xmark")
                        .font(.title3.weight(.semibold))
                        .padding(7)
                        .background(.gray)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 4, x: 0, y: 4)
                })
                Spacer()
            }
            .padding()
            
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
//                            Group { () -> AnyView in
//                                switch locationService.status {
//                                case .noResults: return AnyView(Text("No Results"))
//                                case .error(let description): return AnyView(Text("Error: \(description)"))
//                                default: return AnyView(EmptyView())
//                                }
//                            }.foregroundColor(Color.gray)

                            ForEach(locationService.searchResults, id: \.self) { completion in
                                Button(action: { selectedDestination(completion: completion) }) {
                                    HStack {
                                        Text(completion.title)
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
    DestinationSearchView(locationService: LocationService(), destination: .constant(""))
}

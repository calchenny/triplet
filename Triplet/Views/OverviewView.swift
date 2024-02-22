//
//  OverviewView.swift
//  Triplet
//
//  Created by Derek Ma on 2/20/24.
//

import SwiftUI
import MapKit
import ScalingHeaderScrollView

struct OverviewView: View {
    @State var toggleStates = ToggleStates()
    @State var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 47.608013, longitude: -122.335167), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
    @State var notes: [String] = ["aa", "bbb"]
    
    private let minHeight: CGFloat = 150.0
    private let maxHeight: CGFloat = 300.0

    var body: some View {
        ScalingHeaderScrollView {
            Map(position: $cameraPosition)
        } content: {
            ScrollView {
                LazyVStack {
                    VStack {
                        Text("Most Amazing Trip")
                            .font(.largeTitle)
                        Text("Seattle, WA | 10/20 - 10/25")
                    }
                    .padding(30)
                    DisclosureGroup(isExpanded: $toggleStates.notes) {
                        VStack {
                            ForEach(notes.indices, id: \.self) { index in
                                TextEditor(text: $notes[index])
                                    .padding(10)
                                    .frame(minHeight: 80)
                                    .background(RoundedRectangle(cornerRadius: 10).stroke(.gray, lineWidth: 1))
                                    .cornerRadius(10)
                                    .padding(.top)
                                    .scrollContentBackground(.hidden)
                            }
                            Button {
                                notes.append("New Note")
                            } label: {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add notes")
                                }
                            }
                            .padding(.top)
                        }
                    } label: {
                        HStack {
                            Text("Notes")
                            Spacer()
                            Button {
                                
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                        .padding([.leading, .trailing])
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    Spacer()
                        .frame(height: 30)
                    DisclosureGroup(isExpanded: $toggleStates.housing) {
                        Button {
                            
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add another Lodging")
                            }
                            .padding()
                        }
                    } label: {
                        HStack {
                            Text("Hotel & Lodging")
                            Spacer()
                            Button {
                                
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                        .padding([.leading, .trailing])
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    Spacer()
                        .frame(height: 30)
                    DisclosureGroup(isExpanded: $toggleStates.food) {
                        Button {
                            
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add another food spot")
                            }
                            .padding()
                        }
                    } label: {
                        HStack {
                            Text("Food Spots")
                            Spacer()
                            Button {
                                
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                        .padding([.leading, .trailing])
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
        }
        .height(min: minHeight, max: maxHeight)
        .allowsHeaderCollapse()
        .setHeaderSnapMode(.immediately)
        .ignoresSafeArea()
    }
}

struct ToggleStates {
    var notes: Bool = true
    var housing: Bool = true
    var food: Bool = true
}

#Preview {
    OverviewView()
}


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
    @State private var toggleStates = ToggleStates()
    
    private let minHeight: CGFloat = 150.0
    private let maxHeight: CGFloat = 300.0

    var body: some View {
       ScalingHeaderScrollView {
           ZStack(alignment: .bottom) {
               Map {
                   Marker("Seattle", coordinate: CLLocationCoordinate2D(latitude: 47.608013, longitude: -122.335167))
                       .tint(.blue)
               }
           }
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
                        Button {
                            
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add another Lodging")
                                Spacer()
                            }
                            .padding()
                        }
                    } label: {
                        HStack {
                            Text("Food")
                            Spacer()
                            Button {
                                
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                        .padding([.leading, .trailing])
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .disclosureGroupStyle(DisclosureStyle())
                    Spacer()
                    DisclosureGroup(isExpanded: $toggleStates.housing) {
                        Button {
                            
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add another Lodging")
                                Spacer()
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
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .disclosureGroupStyle(DisclosureStyle())
                    Spacer()
                    DisclosureGroup(isExpanded: $toggleStates.food) {
                        Button {
                            
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add another food spot")
                                Spacer()
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
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .disclosureGroupStyle(DisclosureStyle())
                }
            }
        }
        .height(min: minHeight, max: maxHeight)
        .allowsHeaderCollapse()
        .ignoresSafeArea()
    }
}

struct ToggleStates {
    var notes: Bool = false
    var housing: Bool = false
    var food: Bool = false
}

struct DisclosureStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(configuration.isExpanded ? 90 : 0))
                    .foregroundStyle(.tertiary)
                configuration.label
            }
            if configuration.isExpanded {
                configuration.content
            }
        }
    }
}

#Preview {
    OverviewView()
}


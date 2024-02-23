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
    @State var notes: [Note] = []
    @State var showAlert: Bool = false
    @State var newNoteTitle: String = ""
    
    private let minHeight: CGFloat = 150.0
    private let maxHeight: CGFloat = 300.0
    
    func addNote() {
        guard !newNoteTitle.isEmpty else {
            print("Note name must be non-empty")
            return
        }
        withAnimation {
            notes.append(Note(title: newNoteTitle))
            newNoteTitle = ""
        }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScalingHeaderScrollView {
                    ZStack(alignment: .topLeading) {
                        Map(position: $cameraPosition)
                        Button {
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .padding()
                                .background(.white)
                                .clipShape(Circle())
                        }
                        .padding(.top, 50)
                        .padding(.leading)
                        .tint(.primary)
                    }
                } content: {
                    VStack {
                        Text("Most Amazing Trip")
                            .font(.largeTitle)
                        Text("Seattle, WA | 10/20 - 10/25")
                    }
                    .padding(30)
                    DisclosureGroup(isExpanded: $toggleStates.notes) {
                        VStack {
                            ForEach(notes, id: \.id) { note in
                                NavigationLink {
                                    EmptyView()
                                } label: {
                                    HStack {
                                        Text(note.title)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.tertiary)
                                    }
                                    .padding([.leading, .trailing])
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top)
                            }
                            Button {
                                showAlert.toggle()
                            } label: {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add notes")
                                }
                            }
                            .padding(.top)
                            .alert("Add New Note", isPresented: $showAlert) {
                                TextField("Enter note title", text: $newNoteTitle)
                                Button("Add", action: addNote)
                                Button("Cancel", role: .cancel) { }
                            } message: {
                                Text("Please enter a title for the new note")
                            }
                        }
                    } label: {
                        Text("Notes")
                            .font(.title2)
                    }
                    .frame(maxWidth: geometry.size.width * 0.85)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .tint(.primary)
                    Spacer()
                        .frame(height: 15)
                    DisclosureGroup(isExpanded: $toggleStates.housing) {
                        Button {
                            
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add another Lodging")
                            }
                        }
                        .padding(.top)
                    } label: {
                        Text("Hotel & Lodging")
                            .font(.title2)
                    }
                    .frame(maxWidth: geometry.size.width * 0.85)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .tint(.primary)
                    Spacer()
                        .frame(height: 15)
                    DisclosureGroup(isExpanded: $toggleStates.food) {
                        Button {
                            
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add another food spot")
                            }
                        }
                        .padding(.top)
                    } label: {
                        Text("Food Spots")
                            .font(.title2)
                    }
                    .frame(maxWidth: geometry.size.width * 0.85)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .tint(.primary)
                }
                .height(min: minHeight, max: maxHeight)
                .allowsHeaderCollapse()
                .setHeaderSnapMode(.immediately)
                .ignoresSafeArea()
            }
        }
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


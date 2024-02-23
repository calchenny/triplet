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
    @EnvironmentObject var viewModel: OverviewViewModel

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScalingHeaderScrollView {
                    ZStack(alignment: .topLeading) {
                        Map(position: $viewModel.cameraPosition)
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
                    DisclosureGroup(isExpanded: $viewModel.toggleStates.notes) {
                        VStack {
                            ForEach(viewModel.notes, id: \.id) { note in
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
                                viewModel.showAlert.toggle()
                            } label: {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add notes")
                                }
                            }
                            .padding(.top)
                            .alert("Add New Note", isPresented: $viewModel.showAlert) {
                                TextField("Enter note title", text: $viewModel.newNoteTitle)
                                Button("Add", action: viewModel.addNote)
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
                    DisclosureGroup(isExpanded: $viewModel.toggleStates.housing) {
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
                    DisclosureGroup(isExpanded: $viewModel.toggleStates.food) {
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
                .height(min: viewModel.minHeight, max: viewModel.maxHeight)
                .allowsHeaderCollapse()
                .setHeaderSnapMode(.immediately)
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    OverviewView()
        .environmentObject(OverviewViewModel())
}


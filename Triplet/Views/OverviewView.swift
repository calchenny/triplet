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
    @StateObject var viewModel = OverviewViewModel()
    
    func getHeaderWidth(screenWidth: CGFloat) -> CGFloat {
        let maxWidth = screenWidth * 0.9
        let minWidth = screenWidth * 0.5
        return max((1 - viewModel.collapseProgress + 0.5 * viewModel.collapseProgress) * maxWidth, minWidth)
    }
    
    func getHeaderHeight() -> CGFloat {
        let maxHeight = CGFloat(100)
        let minHeight = CGFloat(60)
        return max((1 - viewModel.collapseProgress + 0.5 * viewModel.collapseProgress) * maxHeight, minHeight)
    }
    
    func getHeaderTitleSize() -> CGFloat {
        let maxSize = CGFloat(30)
        let minSize = CGFloat(16)
        return max((1 - viewModel.collapseProgress + 0.5 * viewModel.collapseProgress) * maxSize, minSize)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScalingHeaderScrollView {
                    ZStack(alignment: .topLeading) {
                        ZStack(alignment: .bottom) {
                            Map(position: $viewModel.cameraPosition)
                            RoundedRectangle(cornerRadius: 15)
                                .frame(width: getHeaderWidth(screenWidth: geometry.size.width), height: getHeaderHeight())
                                .foregroundStyle(.white)
                                .overlay(
                                    VStack {
                                        Text("Most Amazing Trip")
                                            .font(.system(size: getHeaderTitleSize(), weight: .bold))
                                            .foregroundStyle(.indigo)
                                        Text("Seattle, WA | 10/20 - 10/25")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(.indigo)
                                    }
                                )
                                .padding(.bottom, 30)
                        }
                        Button {
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .padding()
                                .background(.indigo)
                                .foregroundStyle(.white)
                                .clipShape(Circle())
                        }
                        .padding(.top, 60)
                        .padding(.leading)
                        .tint(.primary)
                    }
                    .frame(maxWidth: .infinity)
                } content: {
                    Text("Overview")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.indigo)
                        .padding(25)
                    DisclosureGroup(isExpanded: $viewModel.toggleStates.notes) {
                        VStack {
                            ForEach(viewModel.notes, id: \.id) { note in
                                NavigationLink {
                                    NoteView(note: note)
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
                                        .font(.system(size: 16, weight: .medium))
                                    Spacer()
                                }
                                .padding(.bottom, 5)
                                .tint(.gray)
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
                            .font(.system(size: 24, weight: .bold))
                    }
                    .frame(maxWidth: geometry.size.width * 0.85)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .tint(.indigo)
                    Spacer()
                        .frame(height: 15)
                    DisclosureGroup(isExpanded: $viewModel.toggleStates.housing) {
                        Button {
                            
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add another lodging")
                                    .font(.system(size: 16, weight: .medium))
                                Spacer()
                            }
                            .padding(.bottom, 5)
                            .tint(.gray)
                        }
                        .padding(.top)
                    } label: {
                        Text("Hotel & Lodging")
                            .font(.system(size: 24, weight: .bold))
                    }
                    .frame(maxWidth: geometry.size.width * 0.85)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .tint(.indigo)
                    Spacer()
                        .frame(height: 15)
                    DisclosureGroup(isExpanded: $viewModel.toggleStates.food.all) {
                        Button {
                            
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add another food spot")
                                    .font(.system(size: 16, weight: .medium))
                                Spacer()
                            }
                            .padding(.bottom, 5)
                            .tint(.gray)
                        }
                        .padding(.top)
                        DisclosureGroup(isExpanded: $viewModel.toggleStates.food.breakfast) {
                            
                        } label: {
                            Text("Breakfast/Brunch")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .padding([.top, .leading, .trailing])
                        DisclosureGroup(isExpanded: $viewModel.toggleStates.food.lunch) {
                            
                        } label: {
                            Text("Lunch")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .padding([.top, .leading, .trailing])
                        DisclosureGroup(isExpanded: $viewModel.toggleStates.food.dinner) {
                            
                        } label: {
                            Text("Dinner")
                                .font(.system(size: 20, weight: .bold))
                        }
                        .padding([.top, .leading, .trailing, .bottom])
                    } label: {
                        Text("Food Spots")
                            .font(.system(size: 24, weight: .bold))
                    }
                    .frame(maxWidth: geometry.size.width * 0.85)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .tint(.indigo)
                }
                .height(min: viewModel.minHeight, max: viewModel.maxHeight)
                .allowsHeaderCollapse()
                .collapseProgress($viewModel.collapseProgress)
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


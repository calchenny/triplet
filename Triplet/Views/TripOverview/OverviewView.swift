//
//  OverviewView.swift
//  Triplet
//
//  Created by Derek Ma on 2/20/24.
//

import SwiftUI
import MapKit
import ScalingHeaderScrollView
import PopupView

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
            ScalingHeaderScrollView {
                ZStack(alignment: .topLeading) {
                    ZStack(alignment: .bottom) {
                        Map(position: $viewModel.cameraPosition)
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: getHeaderWidth(screenWidth: UIScreen.main.bounds.width), height: getHeaderHeight())
                            .foregroundStyle(Color("Even Lighter Blue"))
                            .overlay(
                                VStack {
                                    Text("Most Amazing Trip")
                                        .font(.custom("Poppins-Bold", size: getHeaderTitleSize()))
                                        .foregroundStyle(Color("Dark Blue"))
                                    Text("Seattle, WA | 10/20 - 10/25")
                                        .font(.custom("Poppins-Medium", size: 13))
                                        .foregroundStyle(Color("Dark Blue"))
                                }
                            )
                            .padding(.bottom, 30)
                    }
                    Button {
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .padding()
                            .background(Color("Dark Blue"))
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
                    .font(.custom("Poppins-Bold", size: 30))
                    .foregroundStyle(Color("Dark Blue"))
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
                                    .font(.custom("Poppins-Medium", size: 16))
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
                        .font(.custom("Poppins-Bold", size: 24))
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .tint(Color("Dark Blue"))
                Spacer()
                    .frame(height: 15)
                DisclosureGroup(isExpanded: $viewModel.toggleStates.housing) {
                    Button {
                        viewModel.showHousingPopup.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add another lodging")
                                .font(.custom("Poppins-Medium", size: 16))
                            Spacer()
                        }
                        .padding(.bottom, 5)
                        .tint(.gray)
                    }
                    .padding(.top)
                } label: {
                    Text("Hotel & Lodging")
                        .font(.custom("Poppins-Bold", size: 24))
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .tint(Color("Dark Blue"))
                Spacer()
                    .frame(height: 15)
                DisclosureGroup(isExpanded: $viewModel.toggleStates.food.all) {
                    Button {
                        viewModel.showFoodPopup.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add another food spot")
                                .font(.custom("Poppins-Medium", size: 16))
                            Spacer()
                        }
                        .padding(.bottom, 5)
                        .tint(.gray)
                    }
                    .padding(.top)
                    DisclosureGroup(isExpanded: $viewModel.toggleStates.food.breakfast) {
                        
                    } label: {
                        Text("Breakfast/Brunch")
                            .font(.custom("Poppins-Bold", size: 20))
                    }
                    .padding([.top, .leading, .trailing])
                    DisclosureGroup(isExpanded: $viewModel.toggleStates.food.lunch) {
                        
                    } label: {
                        Text("Lunch")
                            .font(.custom("Poppins-Bold", size: 20))
                    }
                    .padding([.top, .leading, .trailing])
                    DisclosureGroup(isExpanded: $viewModel.toggleStates.food.dinner) {
                        
                    } label: {
                        Text("Dinner")
                            .font(.custom("Poppins-Bold", size: 20))
                    }
                    .padding([.top, .leading, .trailing, .bottom])
                } label: {
                    Text("Food Spots")
                        .font(.custom("Poppins-Bold", size: 24))
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .tint(Color("Dark Blue"))
            }
            .height(min: viewModel.minHeight, max: viewModel.maxHeight)
            .allowsHeaderCollapse()
            .collapseProgress($viewModel.collapseProgress)
            .setHeaderSnapMode(.immediately)
            .ignoresSafeArea()
            .popup(isPresented: $viewModel.showFoodPopup) {
                FoodPopupView()
                    .environmentObject(viewModel)
            } customize: { popup in
                popup
                    .type(.floater())
                    .position(.center)
                    .animation(.spring())
                    .closeOnTap(false)
                    .closeOnTapOutside(false)
                    .useKeyboardSafeArea(true)
                    .backgroundColor(.black.opacity(0.25))
            }
            .popup(isPresented: $viewModel.showHousingPopup) {
                HousingPopupView()
                    .environmentObject(viewModel)
            } customize: { popup in
                popup
                    .type(.floater())
                    .position(.center)
                    .animation(.spring())
                    .closeOnTap(false)
                    .closeOnTapOutside(false)
                    .useKeyboardSafeArea(true)
                    .backgroundColor(.black.opacity(0.25))
            }
        }
    }
}

#Preview {
    OverviewView()
}

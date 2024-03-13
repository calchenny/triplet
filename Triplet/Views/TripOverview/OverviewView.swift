//
//  OverviewView.swift
//  Triplet
//
//  Created by Derek Ma on 2/20/24.
//

import SwiftUI
import MapKit
import Firebase
import ScalingHeaderScrollView
import PopupView

struct OverviewView: View {
    @StateObject var viewModel = OverviewViewModel()
    var tripId: String
    
    init(tripId: String) {
        self.tripId = tripId
    }
    
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
    
    func getDateString(date: Date?, includeTime: Bool = false) -> String {
        guard let date else {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = includeTime ? "MM/dd, h:mm a" : "MM/dd"
        return dateFormatter.string(from: date)
    }

    var body: some View {
        ScalingHeaderScrollView {
            ZStack(alignment: .topLeading) {
                ZStack(alignment: .bottom) {
                    Map(position: Binding(
                        get: {
                            guard let cameraPosition = viewModel.cameraPosition else {
                                return MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 47.608013, longitude: -122.335167), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
                            }
                            return cameraPosition
                        },
                        set: { viewModel.cameraPosition = $0 }
                    ))
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: getHeaderWidth(screenWidth: UIScreen.main.bounds.width), height: getHeaderHeight())
                        .foregroundStyle(Color("Even Lighter Blue"))
                        .overlay(
                            VStack {
                                if let trip = viewModel.trip {
                                    Text(trip.name)
                                        .font(.custom("Poppins-Bold", size: getHeaderTitleSize()))
                                        .foregroundStyle(Color("Dark Blue"))
                                    Text("\(trip.city), \(trip.state) | \(getDateString(date: trip.start)) - \(getDateString(date: trip.end))")
                                        .font(.custom("Poppins-Medium", size: 13))
                                        .foregroundStyle(Color("Dark Blue"))
                                }
                            }
                        )
                        .padding(.bottom, 30)
                }
                NavigationLink {
                } label: {
                    Image(systemName: "house")
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
                                .environmentObject(viewModel)
                        } label: {
                            HStack {
                                Text(note.title)
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundStyle(.black)
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
                VStack {
                    ForEach(viewModel.housing, id: \.id) { housing in
                        HStack {
                            Image(systemName: "house")
                                .foregroundStyle(Color("Dark Blue"))
                                .font(.title2)
                            Spacer()
                                .frame(maxWidth: 20)
                            VStack(alignment: .leading) {
                                Text(housing.name)
                                    .font(.custom("Poppins-Medium", size: 16))
                                Text(housing.address)
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                    }
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
                }
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
                    let breakfast = viewModel.food.compactMap { food -> Event? in
                        guard let category = food.category else {
                            return nil
                        }
                        guard category == FoodCategory.breakfast else {
                            return nil
                        }
                        return food
                    }
                    ForEach(breakfast, id: \.id) { event in
                        HStack {
                            Image(systemName: "cup.and.saucer")
                                .foregroundStyle(Color("Dark Blue"))
                                .font(.title2)
                            Spacer()
                                .frame(maxWidth: 20)
                            VStack(alignment: .leading) {
                                Text(event.name)
                                    .font(.custom("Poppins-Medium", size: 16))
                                Text("\(getDateString(date: event.start, includeTime: true)) - \(getDateString(date: event.end, includeTime: true))")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundStyle(.secondary)
                                Text(event.address)
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.top)
                    }
                    
                } label: {
                    Text("Breakfast/Brunch")
                        .font(.custom("Poppins-Bold", size: 20))
                }
                .padding([.top, .leading, .trailing])
                DisclosureGroup(isExpanded: $viewModel.toggleStates.food.lunch) {
                    let lunch = viewModel.food.compactMap { food -> Event? in
                        guard let category = food.category else {
                            return nil
                        }
                        guard category == FoodCategory.lunch else {
                            return nil
                        }
                        return food
                    }
                    ForEach(lunch, id: \.id) { event in
                        HStack {
                            Image(systemName: "takeoutbag.and.cup.and.straw")
                                .foregroundStyle(Color("Dark Blue"))
                                .font(.title2)
                            Spacer()
                                .frame(maxWidth: 20)
                            VStack(alignment: .leading) {
                                Text(event.name)
                                    .font(.custom("Poppins-Medium", size: 16))
                                Text("\(getDateString(date: event.start, includeTime: true)) - \(getDateString(date: event.end, includeTime: true))")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundStyle(.secondary)
                                Text(event.address)
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.top)
                    }
                } label: {
                    Text("Lunch")
                        .font(.custom("Poppins-Bold", size: 20))
                }
                .padding([.top, .leading, .trailing])
                DisclosureGroup(isExpanded: $viewModel.toggleStates.food.dinner) {
                    let dinner = viewModel.food.compactMap { food -> Event? in
                        guard let category = food.category else {
                            return nil
                        }
                        guard category == FoodCategory.dinner else {
                            return nil
                        }
                        return food
                    }
                    ForEach(dinner, id: \.id) { event in
                        HStack {
                            Image(systemName: "wineglass")
                                .foregroundStyle(Color("Dark Blue"))
                                .font(.title2)
                            Spacer()
                                .frame(maxWidth: 20)
                            VStack(alignment: .leading) {
                                Text(event.name)
                                    .font(.custom("Poppins-Medium", size: 16))
                                Text("\(getDateString(date: event.start, includeTime: true)) - \(getDateString(date: event.end, includeTime: true))")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundStyle(.secondary)
                                Text(event.address)
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.top)
                    }
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
        .onAppear {
            viewModel.subscribe(tripId: tripId)
        }
        .onDisappear {
            viewModel.unsubscribe()
        }
    }
}

#Preview {
    OverviewView(tripId: "bXQdm19F9v2DbjS4VPyi")
}

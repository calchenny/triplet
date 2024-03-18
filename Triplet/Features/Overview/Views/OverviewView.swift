//
//  OverviewView.swift
//  Triplet
//
//  Created by Derek Ma on 2/20/24.
//

import SwiftUI
import Firebase
import ScalingHeaderScrollView
import PopupView

struct OverviewView: View {
    var tripId: String
    @StateObject var overviewViewModel = OverviewViewModel()
    @EnvironmentObject var tripViewModel: TripViewModel

    var body: some View {
        VStack {
            Text("Overview")
                .font(.custom("Poppins-Bold", size: 30))
                .foregroundStyle(Color("Dark Teal"))
                .padding(.top, 25)
                .padding([.leading, .trailing])
            DisclosureGroup(isExpanded: $overviewViewModel.toggleStates.notes) {
                VStack {
                    ForEach(overviewViewModel.notes, id: \.id) { note in
                        NavigationLink {
                            NoteView(tripId: tripId, note: note)
                                .environmentObject(overviewViewModel)
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
                        overviewViewModel.showAlert.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add notes")
                                .font(.custom("Poppins-Regular", size: 16))
                            Spacer()
                        }
                        .padding(.bottom, 5)
                        .tint(.gray)
                    }
                    .padding(.top)
                    .alert("Add New Note", isPresented: $overviewViewModel.showAlert) {
                        TextField("Enter note title", text: $overviewViewModel.newNoteTitle)
                        Button("Add") {
                            overviewViewModel.addNote(tripId: tripId)
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Please enter a title for the new note")
                    }
                }
            } label: {
                Text("Notes")
                    .font(.custom("Poppins-Bold", size: 20))
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .tint(Color("Dark Teal"))
            Spacer()
                .frame(height: 15)
            DisclosureGroup(isExpanded: $overviewViewModel.toggleStates.housing) {
                VStack {
                    ForEach(overviewViewModel.housing, id: \.id) { housing in
                        HStack {
                            Image(systemName: "house")
                                .foregroundStyle(Color("Dark Teal"))
                                .font(.title2)
                                .padding(5)
                            Spacer()
                            VStack(alignment: .leading) {
                                Text(housing.name)
                                    .font(.custom("Poppins-Medium", size: 16))
                                Text("\(getDateString(date: housing.start, includeTime: true)) - \(getDateString(date: housing.end, includeTime: true))")
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundStyle(.secondary)
                                Text(housing.address)
                                    .font(.custom("Poppins-Regular", size: 12))
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button {
                                
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.title2)
                            }
                        }
                        .padding([.top, .leading, .trailing])
                    }
                    Button {
                        overviewViewModel.showHousingPopup.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add another lodging")
                                .font(.custom("Poppins-Regular", size: 16))
                            Spacer()
                        }
                        .padding(.top)
                        .padding(.bottom, 5)
                        .tint(.gray)
                    }
                }
            } label: {
                Text("Hotel & Lodging")
                    .font(.custom("Poppins-Bold", size: 20))
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .tint(Color("Dark Teal"))
            Spacer()
                .frame(height: 15)
            DisclosureGroup(isExpanded: $overviewViewModel.toggleStates.food.all) {
                Button {
                    overviewViewModel.showFoodPopup.toggle()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add another food spot")
                            .font(.custom("Poppins-Regular", size: 16))
                        Spacer()
                    }
                    .padding(.bottom, 5)
                    .tint(.gray)
                }
                .padding(.top)
                DisclosureGroup(isExpanded: $overviewViewModel.toggleStates.food.breakfast) {
                    let breakfast = overviewViewModel.food.compactMap { food -> Event? in
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
                                .foregroundStyle(Color("Dark Teal"))
                                .font(.title2)
                                .padding(5)
                            Spacer()
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
                            Button {
                                
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.title2)
                            }
                        }
                        .padding(.top)
                    }
                    
                } label: {
                    Text("Breakfast/Brunch")
                        .font(.custom("Poppins-Bold", size: 20))
                }
                .padding([.top, .leading, .trailing])
                DisclosureGroup(isExpanded: $overviewViewModel.toggleStates.food.lunch) {
                    let lunch = overviewViewModel.food.compactMap { food -> Event? in
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
                                .foregroundStyle(Color("Dark Teal"))
                                .font(.title2)
                                .padding(5)
                            Spacer()
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
                            Button {
                                
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.title2)
                            }
                        }
                        .padding(.top)
                    }
                } label: {
                    Text("Lunch")
                        .font(.custom("Poppins-Bold", size: 20))
                }
                .padding([.top, .leading, .trailing])
                DisclosureGroup(isExpanded: $overviewViewModel.toggleStates.food.dinner) {
                    let dinner = overviewViewModel.food.compactMap { food -> Event? in
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
                                .foregroundStyle(Color("Dark Teal"))
                                .font(.title2)
                                .padding(5)
                            Spacer()
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
                            Button {
                                
                            } label: {
                                Image(systemName: "ellipsis")
                                    .font(.title2)
                            }
                        }
                        .padding(.top)
                    }
                } label: {
                    Text("Dinner")
                        .font(.custom("Poppins-Bold", size: 20))
                }
                .padding()
            } label: {
                Text("Food Spots")
                    .font(.custom("Poppins-Bold", size: 20))
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .tint(Color("Dark Teal"))
        }
        .popup(isPresented: $overviewViewModel.showFoodPopup) {
            FoodPopupView(tripId: tripId)
                .environmentObject(overviewViewModel)
        } customize: { popup in
            popup
                .type(.floater())
                .position(.center)
                .animation(.spring())
                .closeOnTap(false)
                .closeOnTapOutside(false)
                .isOpaque(true)
                .backgroundColor(.black.opacity(0.25))
        }
        .popup(isPresented: $overviewViewModel.showHousingPopup) {
            HousingPopupView(tripId: tripId)
                .environmentObject(overviewViewModel)
        } customize: { popup in
            popup
                .type(.floater())
                .position(.center)
                .animation(.spring())
                .closeOnTap(false)
                .closeOnTapOutside(false)
                .isOpaque(true)
                .backgroundColor(.black.opacity(0.25))
        }
        .onAppear {
            overviewViewModel.subscribe(tripId: tripId)
        }
        .onDisappear {
            overviewViewModel.unsubscribe()
        }
    }
}

#Preview {
    OverviewView(tripId: "9xXh1qW2Yh9dRT5qYT0m")
        .environmentObject(TripViewModel())
}

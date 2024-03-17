//
//  AddPlaceView.swift
//  Triplet
//
//  Created by Andy Lam on 2/28/24.
//
import SwiftUI
import MapKit
import FirebaseFirestore

struct AddPlaceView: View {
    var tripId: String
    @EnvironmentObject var itineraryModel: ItineraryViewModel
    @EnvironmentObject var tripViewModel: TripViewModel
    
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var category: EventType = .attraction
    @State var showAlert: Bool = false
    @State private var selectedLandmark: Landmark?
    @Environment(\.presentationMode) var presentationMode
    
    @State private var search: String = ""
    
    @State private var landmarks: [Landmark] = [Landmark]()
    
    private func getNearByLandmarks() {
        guard let trip = tripViewModel.trip else {
            print("Missing trip")
            return
        }

        let request = MKLocalSearch.Request()
        request.pointOfInterestFilter = .includingAll
        request.naturalLanguageQuery = "\(search) \(trip.city) \(trip.state)"
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: trip.destination.latitude, longitude: trip.destination.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, error in
            if let response = response {
                self.landmarks = response.mapItems.compactMap { Landmark(placemark: $0.placemark) }
            }
        }
    }
    
    // Function to convert a string to EventType
    func eventTypeFromString(_ category: String) -> EventType? {
        return EventType(rawValue: category)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.white)
            VStack {
                ZStack(alignment: .trailing) {
                    HStack {
                        Text("Add Event")
                            .font(.custom("Poppins-Bold", size: 30))
                            .foregroundStyle(Color("Dark Teal"))
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    Button {
                        itineraryModel.showNewPlacePopUp.toggle()
                    } label: {
                        Circle()
                            .frame(maxWidth: 30)
                            .foregroundStyle(Color("Dark Teal"))
                            .overlay {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.white)
                            }
                    }
                }
                .padding(.top, 10)
                ZStack(alignment: .trailing) {
                    TextField("Search for an event", text: $search)
                        .padding(20)
                        .frame(maxHeight: 35)
                        .font(.custom("Poppins-Regular", size: 16))
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color("Darker Gray")))
                        .onChange(of: search) {
                            getNearByLandmarks()
                        }
                    Image(systemName: "magnifyingglass")
                        .padding(.trailing)
                        .foregroundStyle(.darkerGray)
                }
                .padding(.bottom)
                VStack(alignment: .leading) {
                    Text("\(landmarks.count) Results")
                        .font(.custom("Poppins-Regular", size: 14))
                    ScrollView {
                        VStack(spacing: 5) {
                            ForEach(landmarks) { landmark in
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(landmark == selectedLandmark ? .lighterGray : .white)
                                    HStack {
                                        Image(systemName: "mappin.and.ellipse")
                                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                            .padding(.trailing)
                                            .foregroundStyle(.darkTeal)
                                        VStack(alignment: .leading) {
                                            Text(landmark.name)
                                                .font(.custom("Poppins-Regular", size: 14))
                                            Text(landmark.address)
                                                .foregroundStyle(.darkerGray)
                                                .font(.custom("Poppins-Regular", size: 12))
                                        }
                                        Spacer()
                                    }
                                    .padding(5)
                                }
                                .onTapGesture {
                                    selectedLandmark = selectedLandmark == landmark ? nil : landmark
                                }
                            }
                        }
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: 300)
                }
                if let trip = tripViewModel.trip {
                    DatePicker(selection: $startDate, in: trip.start...trip.end , displayedComponents: [.date, .hourAndMinute]) {
                        Text("Start:")
                            .font(.custom("Poppins-Medium", size: 16))
                    }
                    .tint(.darkTeal)

                    DatePicker(selection: $endDate, in: startDate...trip.end , displayedComponents: [.date, .hourAndMinute]) {
                        Text("End:")
                            .font(.custom("Poppins-Medium", size: 16))
                    }
                    .tint(.darkTeal)
                    
                    
                }
                HStack(alignment: .center, spacing: 15) {
                    Text("Category")
                        .font(.custom("Poppins-Medium", size: 16))
                    Spacer()
                    Menu {
                        Picker("", selection: $category) {
                            ForEach(EventType.allCases, id: \.self) { category in
                                Text(category.rawValue)
                            }
                        }
                    } label: {
                        HStack {
                            Text(category.rawValue)
                                .font(.custom("Poppins-Regular", size: 16))
                                .frame(minWidth: 150)
                                .foregroundStyle(.black)
                            Image(systemName: "chevron.down")
                                .foregroundStyle(Color("Darker Gray"))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 25)
                    .padding(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color("Darker Gray")))
                }
                Button {
                    guard let selectedLandmark else {
                        showAlert.toggle()
                        return
                    }
                    itineraryModel.addEvent(name: selectedLandmark.name,
                                            location: GeoPoint(latitude: selectedLandmark.coordinate.latitude,
                                                               longitude: selectedLandmark.coordinate.longitude),
                                            type: category,
                                            category: nil,
                                            start: startDate,
                                            address: selectedLandmark.address,
                                            end: endDate,
                                            tripId: tripId)
                                                   
                    itineraryModel.showNewPlacePopUp.toggle()
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 200, height: 40)
                        .foregroundStyle(Color("Dark Teal"))
                        .overlay(
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Event")
                                    .font(.custom("Poppins-Medium", size: 16))
                            }
                                .tint(.white)
                        )
                        .padding([.top, .bottom])
                }
                .alert("No Place Selected", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Please select a place")
                }
            }
            .padding(20)
        }
        .padding()
        .frame(maxHeight: 650)
        .onAppear() {
            if let trip = tripViewModel.trip {
                endDate = trip.start
                startDate = trip.start
            }
            
        }
    }
}

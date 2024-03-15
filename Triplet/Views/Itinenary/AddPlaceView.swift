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

    @EnvironmentObject var itineraryModel: ItineraryViewModel
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var category: EventType = .attraction
    @State var showAlert: Bool = false
    @State private var selectedLandmark: LandmarkViewModel?
    @Environment(\.presentationMode) var presentationMode
    
    @State private var search:String = ""
    
    @State private var landmarks: [LandmarkViewModel] = [LandmarkViewModel]()
    
    private func getNearByLandmarks() {
        let request = MKLocalSearch.Request()
        
        guard let city = itineraryModel.trip?.city, let state = itineraryModel.trip?.state else {
            // Handle missing city or state information
            return
        }
        
        request.pointOfInterestFilter = .includingAll
        request.naturalLanguageQuery = "\(search) \(city) \(state)"
                
        let lat = itineraryModel.trip?.destination.latitude ?? 47.608013
        let lon = itineraryModel.trip?.destination.latitude ?? -122.335167
        
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        
        // Limiting the search for events to around the destination
        request.region = region
        
        let search = MKLocalSearch(request: request)
        
        search.start {(response, error) in
            if let response = response {
                var newLandmarks: [LandmarkViewModel] = [] // Create a new array to store filtered landmarks

                for item in response.mapItems {
                    newLandmarks.append(LandmarkViewModel(placemark: item.placemark))
                }
                // Update the landmarks array outside the loop to avoid multiple updates
                self.landmarks = newLandmarks
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
                            .font(.custom("Poppins-Bold", size: 25))
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
                if let trip = itineraryModel.trip,
                    let start = trip.start,
                    let end = trip.end {
                    DatePicker(selection: $startDate, in: start...end, displayedComponents: [.date, .hourAndMinute]) {
                        Text("Start:")
                            .font(.custom("Poppins-Medium", size: 15))
                            .foregroundStyle(Color.darkTeal)
                    }
                    
                    DatePicker(selection: $endDate, in: startDate...end, displayedComponents: [.date, .hourAndMinute]) {
                        Text("End:")
                            .font(.custom("Poppins-Medium", size: 15))
                            .foregroundStyle(Color.darkTeal)
                    }
                    
                    
                }
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
                .padding(.vertical)
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
                                            Text(landmark.title)
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
                HStack(alignment: .center, spacing: 15) {
                    Text("Category")
                        .font(.custom("Poppins-Medium", size: 16))
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
                .padding(.top)
                Button {
                    guard let selectedLandmark else {
                        showAlert.toggle()
                        return
                    }
                    itineraryModel.addEvent(name: selectedLandmark.name, location: GeoPoint(latitude: selectedLandmark.coordinate.latitude, longitude: selectedLandmark.coordinate.longitude),type: category, category: nil, start: startDate, address: selectedLandmark.title, end: endDate)
                                                   
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
            .padding([.leading, .trailing], 20)
        }
        .padding()
        .frame(maxHeight: 600)
        .onAppear() {
            if let trip = itineraryModel.trip,
               let start = trip.start {
                endDate = start
                startDate = start
            }
            
        }
    }
}


private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd"
    return formatter
}()



#Preview {
    AddPlaceView()
        .environmentObject(ItineraryViewModel())
}

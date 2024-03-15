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
        VStack {
            Text("Add a Place")
                .font(.custom("Poppins-Bold", size: 30))
                .padding(.bottom, 30)
                .foregroundStyle(Color.darkTeal)
            if let trip = itineraryModel.trip,
                let start = trip.start,
                let end = trip.end {
                DatePicker(selection: $startDate, in: start...end, displayedComponents: [.date, .hourAndMinute]) {
                    Text("Start:")
                        .font(.custom("Poppins-Medium", size: 20))
                        .foregroundStyle(Color.darkTeal)
                }
                DatePicker(selection: $endDate, in: startDate...end, displayedComponents: [.date, .hourAndMinute]) {
                    Text("End:")
                        .font(.custom("Poppins-Medium", size: 20))
                        .foregroundStyle(Color.darkTeal)
                }
            }

            DropDownPicker(
                selection: $category,
                options: EventType.allCases.map { $0.rawValue }
            )
            .padding(30)
            
            VStack {
                TextField("Search", text: $search, onEditingChanged: { _ in}) {
                    self.getNearByLandmarks()
                }.textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .cornerRadius(10)
                    .font(.custom("Poppins-Medium", size: 20))
                    
                    
                List {
                    ForEach(self.landmarks, id: \.id) { landmark in
                        VStack(alignment: .leading) {
                            Text(landmark.name)
                                .fontWeight(.bold)
                            Text(landmark.title)
                        }
                        .onTapGesture {
                            print("Start date: \(startDate)")
                            selectedLandmark = landmark
                            guard let checkLandMark = selectedLandmark else {
                                return
                            }
                             
                            itineraryModel.addEvent(name: checkLandMark.name, location: GeoPoint(latitude: checkLandMark.coordinate.latitude, longitude: checkLandMark.coordinate.longitude),type: category, category: nil, start: startDate, address: checkLandMark.title, end: endDate)
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        .padding(15)
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd"
    return formatter
}()

enum DropDownPickerState {
    case top
    case bottom
}

struct DropDownPicker: View {
    
    @Binding var selection: EventType
    var state: DropDownPickerState = .bottom
    var options: [String]
    var maxWidth: CGFloat = 180
    
    @State var showDropdown = false
    
    @SceneStorage("drop_down_zindex") private var index = 1000.0
    @State var zindex = 1000.0
    
    var body: some View {
        GeometryReader {
            let size = $0.size
           
            
            VStack(spacing: 0) {
                
                
                if state == .top && showDropdown {
                    OptionsView()
                }
                
                HStack {
                    Text(selection.rawValue)
                        .foregroundStyle(Color.white)
                        .font(.custom("Poppins-Medium", size: 20))
                    
                    
                    Spacer(minLength: 0)
                    
                    Image(systemName: state == .top ? "chevron.up" : "chevron.down")
                        .font(.title3)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees((showDropdown ? -180 : 0)))
                }
                .padding(.horizontal, 15)
                .frame(width: maxWidth, height: 50)
                .background(.darkTeal)
                .contentShape(.rect)
                .onTapGesture {
                    index += 1
                    zindex = index
                    withAnimation(.snappy) {
                        showDropdown.toggle()
                    }
                }
                .zIndex(10)
                
                if state == .bottom && showDropdown {
                    OptionsView()
                }
            }
            .clipped()
            .background(.evenLighterBlue)
            .cornerRadius(10)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray)
            }
            .frame(height: size.height, alignment: state == .top ? .bottom : .top)
            
        }
        .frame(width: maxWidth, height: 50)
        .zIndex(zindex)
    }
    
    
    func OptionsView() -> some View {
        VStack(spacing: 0) {
            ForEach(EventType.allCases, id: \.self) { category in
                HStack {
                    Text(category.rawValue)
                        .foregroundStyle(Color.black)
                    Spacer()
                    Image(systemName: "checkmark")
                        .opacity(selection == category ? 1 : 0)
                }
                .foregroundStyle(selection == category ? Color.primary : Color.gray)
                .animation(.none, value: selection)
                .frame(height: 40)
                .contentShape(.rect)
                .padding(.horizontal, 15)
                .onTapGesture {
                    withAnimation(.snappy) {
                        selection = category
                        showDropdown.toggle()
                    }
                }
            }
        }
        .transition(.move(edge: state == .top ? .bottom : .top))
        .zIndex(1)
    }
}

//#Preview {
//    AddPlaceView()
//}

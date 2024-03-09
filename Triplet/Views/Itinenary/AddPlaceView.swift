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
    @State private var startDate = Date.now
    @State private var startTime: Date = Date()
    @State private var category: EventType = .attraction
    @State private var selectedLandmark: LandmarkViewModel?
    @Environment(\.presentationMode) var presentationMode
    
    @State private var search:String = ""
    @State private var landmarks: [LandmarkViewModel] = [LandmarkViewModel]()
    
    @ObservedObject var locationManager = LocationManager()
    
    private func getNearByLandmarks() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = search
        
        let search = MKLocalSearch(request: request)
        search.start {(response, error) in
            if let response = response {
                let mapItems = response.mapItems
                self.landmarks = mapItems.map {
                    LandmarkViewModel(placemark: $0.placemark)
                }
            }
        }
    }
    
    // Function to convert a string to EventType
    func eventTypeFromString(_ category: String) -> EventType? {
        return EventType(rawValue: category)
    }
    
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2024, month: 10, day: 20)
        let endComponents = DateComponents(year: 2024, month: 10, day:25)
        return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
    }()
    
    var body: some View {
        VStack {
            Text("Add a Place")
                .font(.custom("Poppins-Bold", size: 40))
                .padding(.bottom, 30)
                .foregroundStyle(Color.darkBlue)
            DatePicker(selection: $startDate, in: dateRange, displayedComponents: .date) {
                Text("Date")
                    .font(.custom("Poppins-Medium", size: 20))
                    .foregroundStyle(Color.darkBlue)
            }
            DatePicker(selection: $startTime, displayedComponents: .hourAndMinute) {
                Text("Time")
                    .font(.custom("Poppins-Medium", size: 20))
                    .foregroundStyle(Color.darkBlue)
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
                            print("Start time: \(startTime)")
                            selectedLandmark = landmark
                            guard let checkLandMark = selectedLandmark else {
                                return
                            }
                             
                            itineraryModel.addEvent(name: checkLandMark.name, location: GeoPoint(latitude: checkLandMark.coordinate.latitude, longitude: checkLandMark.coordinate.longitude), type: category, category: nil, start: startDate, time: startTime, end: nil)
                            itineraryModel.fetchEvents()
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
                .background(.darkBlue)
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

#Preview {
    AddPlaceView()
}

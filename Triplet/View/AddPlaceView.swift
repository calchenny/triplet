//
//  AddPlaceView.swift
//  Triplet
//
//  Created by Andy Lam on 2/28/24.
//

import SwiftUI
import MapKit

struct AddPlaceView: View {
//    @Binding var startDate: Date
//    @Binding var endDate: Date
    @EnvironmentObject var itineraryModel: ItineraryModel
    @State private var startDate = Date.now
    @State private var startTime = Date.now
    @State private var category: String = ""
    @State private var selectedLandmark: LandmarkModel?
    @Environment(\.presentationMode) var presentationMode
    
    @State private var search:String = ""
    @State private var landmarks: [LandmarkModel] = [LandmarkModel]()
    
    @ObservedObject var locationManager = LocationManager()
    
    private func getNearByLandmarks() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = search
        
        let search = MKLocalSearch(request: request)
        search.start {(response, error) in
            if let response = response {
                let mapItems = response.mapItems
                self.landmarks = mapItems.map {
                    LandmarkModel(placemark: $0.placemark)
                }
            }
        }
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
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 30)
            DatePicker(selection: $startDate, in: dateRange, displayedComponents: .date) {
                Text("Date")
            }
            DatePicker(selection: $startTime, in: ...Date.now, displayedComponents: .hourAndMinute) {
                Text("Time")
            }
            
            DropDownPicker(
                selection: $category,
                options: [
                    "Restaurant",
                    "Attraction",
                    "Hotel",
                    "Transit",
                ]
            )
            .padding(30)
            
            VStack {
                TextField("Search", text: $search, onEditingChanged: { _ in}) {
                    self.getNearByLandmarks()
                }.textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    
                List {
                    ForEach(self.landmarks, id: \.id) { landmark in
                        VStack(alignment: .leading) {
                            Text(landmark.name)
                                .fontWeight(.bold)
                            Text(landmark.title)
                        }
                        .onTapGesture {
                            selectedLandmark = landmark
                            guard let checkLandMark = selectedLandmark else {
                                return
                            }
                            itineraryModel.addEvent(name: checkLandMark.name, location: checkLandMark.title, date: startDate, time: startTime, category: category)
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
    
    @Binding var selection: String
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
                    Text(selection.isEmpty ? "Category" : selection)
                        .foregroundColor(selection.isEmpty ? .gray : .black)
                    
                    
                    Spacer(minLength: 0)
                    
                    Image(systemName: state == .top ? "chevron.up" : "chevron.down")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees((showDropdown ? -180 : 0)))
                }
                .padding(.horizontal, 15)
                .frame(width: maxWidth, height: 50)
                .background(.white)
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
            .background(.white)
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
            ForEach(options, id: \.self) { option in
                HStack {
                    Text(option)
                        .foregroundStyle(Color.black)
                    Spacer()
                    Image(systemName: "checkmark")
                        .opacity(selection == option ? 1 : 0)
                }
                .foregroundStyle(selection == option ? Color.primary : Color.gray)
                .animation(.none, value: selection)
                .frame(height: 40)
                .contentShape(.rect)
                .padding(.horizontal, 15)
                .onTapGesture {
                    withAnimation(.snappy) {
                        selection = option
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

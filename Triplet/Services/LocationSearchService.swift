//
//  LocationSearchService.swift
//  Triplet
//
//  Created by Calvin Chen on 2/20/24.
//

import Foundation
import Combine
import MapKit

class LocationSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    enum LocationStatus: Equatable {
        case idle
        case isSearching
        case error(String)
    }
    
    struct CityResult: Hashable {
        var city: String
        var state: String
        var country: String
        var latitude: Double
        var longitude: Double
    }
    
    @Published var searchQuery: String = ""
    @Published private(set) var status: LocationStatus = .idle
    @Published private(set) var cityFilterResults: [MKLocalSearchCompletion] = []
    @Published private(set) var searchResults: [CityResult] = []
    
    private var queryCancellable: AnyCancellable?
    private let searchCompleter: MKLocalSearchCompleter!
    
    init(searchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()) {
        self.searchCompleter = searchCompleter
        super.init()
        self.searchCompleter.delegate = self
        
        queryCancellable = $searchQuery
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { fragment in
                self.status = .isSearching
                if !fragment.isEmpty {
                    self.searchCompleter.queryFragment = fragment
                } else {
                    self.status = .idle
                }
            })
    }
    
    func performSearch() {
        searchCompleter.queryFragment = searchQuery
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Filtering so that we only get cities in the United States
        self.cityFilterResults = completer.results.filter { result in
            if !result.title.contains(",") {
                return false
            }

            if result.title.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
                return false
            }

            if result.subtitle.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
                return false
            }

            return true
        }
        
        // Reset scheduleResults if there are no valid city results
        if cityFilterResults.isEmpty {
            self.searchResults = []
            return
        }
        
        getCityList(results: cityFilterResults) { cityResults in
            DispatchQueue.main.async {
                self.searchResults = cityResults
            }
        }
    }
    
    private func getCityList(results: [MKLocalSearchCompletion], completion: @escaping ([CityResult]) -> Void) {
        var searchResults: [CityResult] = []
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            
            dispatchGroup.enter()
            
            let request = MKLocalSearch.Request(completion: result)
            let search = MKLocalSearch(request: request)
            
            search.start { (response, error) in
                defer {
                    dispatchGroup.leave()
                }
                
                guard let response = response else { return }
                
                for item in response.mapItems {
                    if let location = item.placemark.location {
                        
                        let city = item.placemark.locality ?? ""
                        let title = item.placemark.title ?? ""
                        
                        let stateComponents = title.components(separatedBy: ",")

                        let state = stateComponents[1].trimmingCharacters(in: .whitespacesAndNewlines)

                        var country = item.placemark.country ?? ""
                        if country.isEmpty {
                            country = item.placemark.countryCode ?? ""
                        }
                        
                        if !city.isEmpty {
                            let cityResult = CityResult(city: city, state: state, country: country, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                            searchResults.append(cityResult)
                        }
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(searchResults)
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.status = .error(error.localizedDescription)
    }
}

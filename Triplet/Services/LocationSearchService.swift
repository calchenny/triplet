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
    // Enum to track the current status of location search operations
    enum LocationStatus: Equatable {
        case idle
        case isSearching
        case error(String)
    }
    
    // Represents a city result with its geographic details
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
    
    // Initializes the search completer and sets up bindings
    init(searchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()) {
        self.searchCompleter = searchCompleter
        super.init()
        self.searchCompleter.delegate = self
        
        // Reacts to changes in the searchQuery property to initiate searches
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
    
    // Manually trigger a search with the current query
    func performSearch() {
        searchCompleter.queryFragment = searchQuery
    }
    
    // Processses the updated results from a search completer
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Filter results to meet specific criteria (e.g., cities in the United States).
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
        
        // If no valid city results, clear the searchResults.
        if cityFilterResults.isEmpty {
            self.searchResults = []
            return
        }
        
        // Converts filtered MKLocalSearchCompletion objects to CityResult objects.
        getCityList(results: cityFilterResults) { cityResults in
            DispatchQueue.main.async {
                self.searchResults = cityResults
            }
        }
    }
    
    // Converts an array of MKLocalSearchCompletion objects to an array of CityResult objects.
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
                
                // Extracts and transforms the necessary details from each map item into a CityResult.
                for item in response.mapItems {
                    if let location = item.placemark.location {
                        let city = item.placemark.locality ?? ""
                        let title = item.placemark.title ?? ""
                        let stateComponents = title.components(separatedBy: ",")
                        let state = stateComponents[1].trimmingCharacters(in: .whitespacesAndNewlines)
                        var country = item.placemark.country ?? ""
                        country = country.isEmpty ? item.placemark.countryCode ?? "" : country
                        
                        if !city.isEmpty {
                            let cityResult = CityResult(city: city, state: state, country: country, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                            searchResults.append(cityResult)
                        }
                    }
                }
            }
        }
        
        // Once all searches are complete, returns the array of CityResult objects.
        dispatchGroup.notify(queue: .main) {
            completion(searchResults)
        }
    }
    
    // Handles errors from the search completer.
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.status = .error(error.localizedDescription)
    }
}

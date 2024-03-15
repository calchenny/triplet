//
//  APICallsViewModel.swift
//  Triplet
//
//  Created by Newland Luu on 3/13/24.
//

import Foundation


class APICaller: ObservableObject {

    func getWalkScore2() {

        let headers = [
            "X-RapidAPI-Key": "91ed20891fmsh4fdbf2da84b83b0p1f41d1jsn0d920a828bad",
            "X-RapidAPI-Host": "walk-score.p.rapidapi.com"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://walk-score.p.rapidapi.com/score?lat=38.5449&address=1%20Shields%20Ave%2C%20Davis%2C%20CA%2095616&wsapikey=b89e81fdd187be1ff6decff8f1234345&lon=-121.7405")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? "")
            }
        })

        dataTask.resume()
    }

    func getWalkScore(latitude: Double, longitude: Double, address: String, completionHandler: @escaping (Int?, String?, Error?) -> Void) {
        let key = "b89e81fdd187be1ff6decff8f1234345"

        let headers = [
            "X-RapidAPI-Key": "91ed20891fmsh4fdbf2da84b83b0p1f41d1jsn0d920a828bad",
            "X-RapidAPI-Host": "walk-score.p.rapidapi.com"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://walk-score.p.rapidapi.com/score?lat=\(latitude)&address=\(address)&wsapikey=\(key)&lon=\(longitude)")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? "")
            }
        })

        dataTask.resume()
    }


    func yelpRetrieveVenues(eventName: String, longitude: Double, latitude: Double, term: String, completionHandler: @escaping ([String]?, Error?) -> Void) {
        print("inside yelpRetrieveVenues()")
        let limit: Int = 5
        let sortBy: String = "best_match"
        let locale: String = "en_US"
        let apiKey = ProcessInfo.processInfo.environment["YELP_API_KEY"] ?? ""

        let headers = [
            "accept": "application/json",
            "Authorization": "Bearer FwiasY2l76GjWQI7hkhhmuwMoRXv699G-bDsgynfLZBtP8lECbXnGViDQpu0sOrnO9clj9E6LnFedgyGiTZ_sv-ln3TQ4gRcDxqYl9h7QylshWushYJtF9LAtHH0ZXYx"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)&term=\(term)&locale=\(locale)&open_now=true&sort_by=\(sortBy)&limit=\(limit)")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                print("Error: \(error)")
                completionHandler(nil, error)
            } else if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let dictionary = json as? [String: Any], let businesses = dictionary["businesses"] as? [[String: Any]] {

                        var aliases: [String] = []  // Array to store aliases

                        for business in businesses {
                            // Extract business information here and use it as needed
                            if let name = business["name"] as? String {
                                print("Business Name: \(name)")
                                
                                //do not add the location if it is a duplicate to the one we are finding replacements for
                                if name == eventName{
                                    continue
                                }
                            }
                            

                            if let alias = business["alias"] as? String {
                                aliases.append(alias)
                            }
                            // Continue extracting other business properties
                        }

                        //print("Aliases: \(aliases)")
                        completionHandler(aliases, nil)
                    }

                } catch {
                    print("Error parsing JSON: \(error)")
                    completionHandler(nil, error)
                }
            }
        })

        dataTask.resume()
    }

    func yelpLoadSuggestions(alias: String, completionHandler: @escaping ([(String, String, String)]?, Error?) -> Void) {

        print("inside yelpLoadSuggestions")
        let headers = [
            "accept": "application/json",
            "Authorization": "Bearer FwiasY2l76GjWQI7hkhhmuwMoRXv699G-bDsgynfLZBtP8lECbXnGViDQpu0sOrnO9clj9E6LnFedgyGiTZ_sv-ln3TQ4gRcDxqYl9h7QylshWushYJtF9LAtHH0ZXYx"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://api.yelp.com/v3/businesses/\(alias)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            } else if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

                    if let photosArray = json?["photos"] as? [String],
                       let name = json?["name"] as? String, let yelpURL = json?["url"] as? String,
                       let firstPhotoURL = photosArray.first {

                        let result: (String, String, String) = (name, firstPhotoURL, yelpURL)
                        completionHandler([result], nil)
                        print("tuple of (name, photoURL, and yelpURL) successfully returned from yelpLoadSuggestions()")
                        return
                    }

                    // If photos array or name is empty or not present
                    print("return tuple empty")
                    completionHandler(nil, nil)

                } catch {
                    print("there was an error")
                    completionHandler(nil, error)
                }
            }
        })

        dataTask.resume()
    }
}

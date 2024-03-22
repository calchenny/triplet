//
//  APICallsViewModel.swift
//  Triplet
//
//  Created by Newland Luu on 3/13/24.
//

import Foundation


class APICaller: ObservableObject {

    func yelpRetrieveVenues(eventName: String, longitude: Double, latitude: Double, term: String, completionHandler: @escaping ([String]?, Error?) -> Void) {
        print("inside yelpRetrieveVenues()")
        let limit: Int = 5
        let sortBy: String = "best_match"
        let locale: String = "en_US"
        var apiKey = ""
        
        //access info plist
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            print("Info.plist not found")
            return
        }

        let url = URL(fileURLWithPath: path)

        do {
            let data = try Data(contentsOf: url)
            guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
                print("Unable to cast plist to dictionary")
                return
            }
            //if we are able to access, set apiKey equal to the yelpSecret
            if let yelpSecret = plist["YELPSECRET"] as? String {
                //print("Value of 'YELPSECRET': \(specificEntry)")
                apiKey = yelpSecret
                
            } else {
                //print("Entry 'YELPSECRET' not found or is not a string")
            }
        } catch {
            print("Error loading Info.plist: \(error)")
        }



        let headers = [
            "accept": "application/json",
            "Authorization": "Bearer \(apiKey)"
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

    func yelpLoadSuggestions(alias: String, completionHandler: @escaping ([(String, String, String, String)]?, Error?) -> Void) {

        var apiKey = ""
        
        //access info plist
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            print("Info.plist not found")
            return
        }

        let url = URL(fileURLWithPath: path)

        do {
            let data = try Data(contentsOf: url)
            guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
                print("Unable to cast plist to dictionary")
                return
            }
            //if we are able to access, set apiKey equal to the yelpSecret
            if let yelpSecret = plist["YELPSECRET"] as? String {
                //print("Value of 'YELPSECRET': \(specificEntry)")
                apiKey = yelpSecret
                
            } else {
                //print("Entry 'YELPSECRET' not found or is not a string")
            }
        } catch {
            print("Error loading Info.plist: \(error)")
        }
        
        print("inside yelpLoadSuggestions")
        let headers = [
            "accept": "application/json",
            "Authorization": "Bearer \(apiKey)"
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
                        let name = json?["name"] as? String,
                        let yelpURL = json?["url"] as? String,
                        let firstPhotoURL = photosArray.first,
                        let location = json?["location"] as? [String: Any],
                        let address1 = location["address1"] as? String {
                            
                        let result: (String, String, String, String) = (name, firstPhotoURL, yelpURL, address1)
                        completionHandler([result], nil)
                        print("Tuple of (name, photoURL, yelpURL, and address) successfully returned from yelpLoadSuggestions()")
                        print("Address: \(address1)")
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

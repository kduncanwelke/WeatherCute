//
//  Networker.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/29/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

struct Networker {
	private static let session = URLSession(configuration: .default)
	
	static func getURL(endpoint: URL, completion: @escaping (Result<Data>) -> Void) {
		fetchData(url: endpoint, completion: completion)
	}
	
	static func fetchData(url: URL, completion: @escaping (Result<Data>) -> Void) {
		let request = URLRequest(url: url)
		
		let task = session.dataTask(with: request) { data, response, error in
        
			guard let httpResponse = response as? HTTPURLResponse else {
				completion(.failure(Errors.networkError))
				return
			}
           
			// check for status code to prevent blank loading if something is wrong
            if NetworkMonitor.connection == false {
                completion(.failure(Errors.noNetwork))
            } else if httpResponse.statusCode == 200 {
				if let error = error {
					completion(.failure(error))
				} else if let data = data {
					completion(.success(data))
                }
			} else if httpResponse.statusCode == 404 {
				completion(.failure(Errors.noDataError))
            } else {
				completion(.failure(Errors.networkError))
				print("status was not 200")

                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "networkErrorAlert"), object: nil)
                }
			}
		}
		task.resume()
	}
}

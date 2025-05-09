//
//  Networker.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/29/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

struct Networker<T: SearchType> {
    static func fetch() async throws -> T {
        let url = T.endpoint.url()
        
        guard let response: (data: Data, response: URLResponse) = try? await URLSession.shared.data(from: url) else {
            throw Errors.networkError
        }
        
        if let httpResponse = response.response as? HTTPURLResponse {
            if httpResponse.statusCode == 404 {
                throw Errors.noDataError
            } else if httpResponse.statusCode == 500 {
                throw Errors.unexpectedProblem
            } else if httpResponse.statusCode != 200 {
                print("status was not 200")
                print(httpResponse.statusCode)
                throw Errors.networkError
            }
        }
        
        guard let decoded = try? JSONDecoder.nwsApiDecoder.decode(T.self, from: response.data) else {
            throw Errors.noDataError
        }
           
        return decoded
    }
}

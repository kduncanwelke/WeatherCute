//
//  DataManager.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/29/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

// takes generic searchtype conforming object
struct DataManager<T: SearchType> {
    private static func fetch(url: URL, completion: @escaping (Result<T>) -> Void) {
        Networker.fetchData(url: url) { result in
            switch result {
            case .success(let data):
                guard let response = try? JSONDecoder.nwsApiDecoder.decode(T.self, from: data) else {
                    return
                }
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    static func fetch(completion: @escaping (Result<[T]>) -> Void) {
        fetch(url: T.endpoint.url()) { result in
            switch result {
            case .success(let result):
                var data: [T] = []
                data.append(result)
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

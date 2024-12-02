//
//  HTTPClient.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 21.11.2024.
//

import Foundation

typealias HTTPResult = Result<Data, RMError>

enum RMError: Error {
    case invalidURLRequest
    case unableToDecode
    case apiError(error: Error)
    case unknown
}

protocol IHTTPClient {
    func request(target: RmAPI) async -> HTTPResult
}

struct HTTPClient: IHTTPClient {
    func request(target: RmAPI) async -> HTTPResult {
        guard let request = target.request else { return .failure(.invalidURLRequest)}

        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request)
            return .success(data)
        } catch {
            return .failure(.apiError(error: error))
        }
    }
}

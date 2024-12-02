//
//  Dependencies.swift
//  RickAndMorty
//
//  Created by Ilia Ershov on 17.11.2024.
//

import Foundation

protocol IDependencies {
    var container: ModuleContainer { get }
    var client: IHTTPClient { get }
    var networkService: NetworkService { get }
    var storage: Storage { get }
}

final class Dependencies: IDependencies {
    lazy var container: ModuleContainer = ModuleContainer(self)
    lazy var client: IHTTPClient = HTTPClient()
    lazy var networkService: NetworkService = NetworkService(dependencies: self)
    lazy var storage: Storage = Storage()
}

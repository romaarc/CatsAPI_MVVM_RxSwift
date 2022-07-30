//
//  AppDependency.swift
//  CatsAPI_MVVM
//
//  Created by Roman Gorshkov on 23.12.2021.
//

import Foundation

protocol HasDependencies {
    var catsNetworkService: NetworkServiceProtocol { get }
    var catsViewModel: CatViewModelProtocol { get }
}

final class AppDependency {
    private let networkService: NetworkService
    private let catViewModel: CatViewModel

    init(networkService: NetworkService,
         catViewModel: CatViewModel) {
        self.networkService = networkService
        self.catViewModel = catViewModel
    }

    static func makeDefault() -> AppDependency {
        let networkService = NetworkService()
        let catViewModel = CatViewModel(catsNetworkService: networkService)
        return AppDependency(networkService: networkService,
                             catViewModel: catViewModel)
    }
}

extension AppDependency: HasDependencies {
    var catsViewModel: CatViewModelProtocol {
        self.catViewModel
    }

    var catsNetworkService: NetworkServiceProtocol {
        return self.networkService
    }
}

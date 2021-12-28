//
//  NetworkService+Breeds.swift
//  CatsAPI_MVVM
//
//  Created by Roman Gorshkov on 23.12.2021.
//

import Foundation
import RxSwift

extension NetworkService: NetworkServiceProtocol {
    func fetchBreeds(with page: Int) -> Observable<Response> {
        let params = BreedsURLParameters(attach_breed: "", page: page, limit: GlobalConstants.limit)
        let request = URLFactory.getBreedsRequest(params: params)
        return self.baseRequest(request: request)
    }
}

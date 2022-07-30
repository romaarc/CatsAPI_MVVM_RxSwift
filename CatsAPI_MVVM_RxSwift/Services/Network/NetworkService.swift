//
//  NetworkService.swift
//  CatsAPI_MVVM
//
//  Created by Roman Gorshkov on 23.12.2021.
//

import Foundation
import RxSwift
import RxCocoa

enum NetworkErrors: Error {
    case wrongURL
    case dataIsEmpty
    case decodeIsFail
    case noConnection
}

final class NetworkService {
    func baseRequest<T: Decodable>(request: URLRequest) -> Observable<T> {
        return Observable.create { observer in
            let bag = URLSession.shared.rx.data(request: request)
                .subscribe { event in
                    switch event {
                    case .next(let data):
                        do {
                            let decodedModel = try JSONDecoder().decode(T.self, from: data)
                            observer.onNext(decodedModel)
                        }
                        catch {
                            observer.onError(NetworkErrors.decodeIsFail)
                        }
                    case .error(_):
                        observer.onError(NetworkErrors.dataIsEmpty)
                    case .completed:
                        observer.onCompleted()
                    }
                }
            return Disposables.create([bag])
        }
    }
}

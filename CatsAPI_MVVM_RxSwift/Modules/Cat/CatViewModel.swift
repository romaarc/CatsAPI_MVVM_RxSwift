//
//  CatViewModel.swift
//  CatsAPI_MVVM_RxSwift
//
//  Created by Roman Gorshkov on 23.12.2021.
//

import Foundation
import RxSwift
import RxCocoa
import Action

protocol CatViewModelInputs {
    var fetchTrigger: PublishSubject<Void> { get }
    var reachedBottomTrigger: PublishSubject<Void> { get }
}

protocol CatViewModelOutputs {
    var cats: Observable<Response> { get }
    var isLoading: Observable<Bool> { get }
    var error: Observable<Error> { get }
}

protocol CatViewModelType {
    var inputs: CatViewModelInputs { get }
    var outputs: CatViewModelOutputs { get }
}

protocol CatViewModelProtocol: CatViewModelType & CatViewModelInputs &  CatViewModelOutputs {}

final class CatViewModel: CatViewModelProtocol {
    var inputs: CatViewModelInputs { return self }
    var outputs: CatViewModelOutputs { return self }
    // MARK: - Inputs
    let fetchTrigger = PublishSubject<Void>()
    let reachedBottomTrigger = PublishSubject<Void>()
    // MARK: - Outputs
    let cats: Observable<Response>
    let isLoading: Observable<Bool>
    let error: Observable<Error>
    
    private let disposeBag = DisposeBag()
    private let fetchAction: Action<Int, Response>
    private let catsNetworkService: NetworkServiceProtocol
    private let page = BehaviorRelay<Int>(value: GlobalConstants.initialPage)
    
    init(catsNetworkService: NetworkServiceProtocol) {
        self.catsNetworkService = catsNetworkService
        
        self.fetchAction = Action { page in
            return catsNetworkService.fetchBreeds(with: page)
        }
        
        let response = BehaviorRelay<Response>(value: [])
        self.cats = response.asObservable()
       
        self.isLoading = fetchAction.executing.startWith(false)
        self.error = fetchAction.errors.map { _ in NSError(domain: "Error", code: 0, userInfo: nil) }
        
        fetchAction.elements
                    .withLatestFrom(response) { ($0, $1) }
                    .map { $0.1 + $0.0 }
                    .bind(to: response)
                    .disposed(by: disposeBag)
        
        fetchAction.elements
                    .withLatestFrom(page)
                    .map { $0 + 1 }
                    .bind(to: page)
                    .disposed(by: disposeBag)
        
        fetchTrigger
                    .withLatestFrom(page)
                    .bind(to: fetchAction.inputs)
                    .disposed(by: disposeBag)

        reachedBottomTrigger
                    .withLatestFrom(isLoading)
                    .filter { !$0 }
                    .withLatestFrom(page)
                    .filter { $0 < 4 }
                    .bind(to: fetchAction.inputs)
                    .disposed(by: disposeBag)
    }
}

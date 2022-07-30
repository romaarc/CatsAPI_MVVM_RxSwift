//
//  CatViewController.swift
//  CatsAPI_MVVM
//
//  Created by Roman Gorshkov on 23.12.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class CatViewController: BaseViewController {
    private var viewModel: CatViewModelProtocol
    
    init(viewModel: CatViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.outputs.cats
            .observe(on: MainScheduler.instance)
            .bind(to: collectionView.rx.items) { [weak self] collectionView, row, cat in
                guard let self = self else { return UICollectionViewCell() }
                let cell = self.collectionView.dequeueCell(cellType: CatCell.self, for: IndexPath(row: row, section: 0))
                cell.update(with: cat)
                return cell
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(Breed.self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                let detailViewModel = CatDetailViewModel(cat: $0)
                let catDetailVC = CatDetailViewController(viewModel: detailViewModel)
                catDetailVC.modalPresentationStyle = .fullScreen
                self?.navigationController?.pushViewController(catDetailVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.isLoading
            .observe(on: MainScheduler.instance)
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        collectionView.rx.reachedBottom.asObservable()
            .bind(to: viewModel.inputs.reachedBottomTrigger)
            .disposed(by: disposeBag)
        
        viewModel.inputs.fetchTrigger.onNext(())
    }
    
    override func setupCollectionView() {
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.register(CatCell.self)
        collectionView.addSubview(activityIndicator)
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.frame
    }
}

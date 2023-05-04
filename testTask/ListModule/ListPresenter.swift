//
//  ListPresenter.swift
//  testTask
//
//  Created by tixomark on 4/28/23.
//

import Foundation

protocol ListViewProtocol: AnyObject {
    var presenter: ListPresenterProtocol! { get }
    
    func addItemsAt(_ indexPaths: [IndexPath])
    func reloadItem(at index: Int)
    func reloadCollection()
    
}

protocol ListPresenterProtocol {
    func requestNetSetOfItems(text: String)
    func getNumberOfItems() -> Int
    func requestDataForItem(at indexPath: IndexPath) -> Item?
    func didTapOnItem(at indexPath: IndexPath)
}

extension ListPresenter: ServiceObtainableProtocol {
    var neededServices: [Service] {
        [.router, .dataProvider, .networkService]
    }
    
    func getServices(_ services: [Service : ServiceProtocol]) {
        self.router = (services[.router] as! RouterProtocol)
        self.dataProvider = (services[.dataProvider] as! DataProviderProtocol)
        self.networkService = (services[.networkService] as! NetworkServiceProtocol)
    }
}

final class ListPresenter: ListPresenterProtocol {
    var router: RouterProtocol?
    var dataProvider: DataProviderProtocol?
    var networkService: NetworkServiceProtocol?
    
    var lock = pthread_rwlock_t()
    var attr = pthread_rwlockattr_t()
    var items: [Item] {
        get {
            pthread_rwlock_rdlock(&lock)
            let tmp = itemsArr
            pthread_rwlock_unlock(&lock)
            return tmp
        }
        set {
            pthread_rwlock_wrlock(&lock)
            itemsArr = newValue
            pthread_rwlock_unlock(&lock)
        }
    }
    
    private var itemsArr: [Item] = []
    var lastRequest: String = ""
    weak var view: ListViewProtocol!
    
    init(view: ListViewProtocol) {
        self.view = view
        pthread_rwlock_init(&lock, &attr)
    }
    deinit {
        print("deinited ListPresenter")
    }
    
    func requestNetSetOfItems(text: String) {
        let nextBatchStartIndex = lastRequest == text ? items.count : 0
        networkService?.getItemsOn(query: text,
                                   startingFrom: nextBatchStartIndex,
                                   amount: 10,
                                   completion: { result in
            switch result {
            case .success(let items):
                if self.lastRequest != text {
                    self.items = items
                    self.view.reloadCollection()
                    self.lastRequest = text
                } else {
                    self.items.append(contentsOf: items)
                    var indexPaths: [IndexPath] = []
                    (nextBatchStartIndex ..< self.items.count).forEach { index in
                        indexPaths.append(.init(item: index, section: 0))
                    }
                    self.view.addItemsAt(indexPaths)
                }
                self.loadImages()
            case .failure(let error):
                print(error.localizedDescription)
                return
            }
        })
    }
    
    private func loadImages() {
        for (index, item) in items.enumerated() {
            networkService?.downloadImageFor(item: item,
                                             completion: { result in
                switch result {
                case .success(let imageUrl):
                    guard index < self.items.count else {
                        return
                    }
                    self.items[index].imageURL = imageUrl.absoluteString
                    self.view.reloadItem(at: index)
                case .failure(_):
                    return
                }
            })
        }
    }
    
    func getNumberOfItems() -> Int {
        return items.count
    }
    
    func requestDataForItem(at indexPath: IndexPath) -> Item? {
        return items[indexPath.item]
    }
    
    func didTapOnItem(at indexPath: IndexPath) {
        router?.showItemDetailModule(item: items[indexPath.item])
    }
}

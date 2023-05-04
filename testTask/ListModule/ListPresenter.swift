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
    func items(toDelete: [IndexPath], toInsert: [IndexPath])
    func reloadItem(at index: Int)
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
    
    var lock = NSLock()
    var isUpdatingItems: Bool = false
    
    var items: [Item] = []
    var lastRequest: String = ""
    weak var view: ListViewProtocol!
    
    init(view: ListViewProtocol) {
        self.view = view
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
                
                self.lock.lock()
                    if self.lastRequest != text {
                        var indexPathsToRemove: [IndexPath] = []
                        (0 ..< self.items.count).forEach { index in
                            indexPathsToRemove.append(.init(item: index, section: 0))
                        }
                        var indexPathsToInsert: [IndexPath] = []
                        (0 ..< items.count).forEach { index in
                            indexPathsToInsert.append(.init(item: index, section: 0))
                        }
                        self.items = items
                        
                        self.view.items(toDelete: indexPathsToRemove, toInsert: indexPathsToInsert)
                        self.lastRequest = text
                    } else {
                        self.items.append(contentsOf: items)
                        var indexPaths: [IndexPath] = []
                        (nextBatchStartIndex ..< self.items.count).forEach { index in
                            indexPaths.append(.init(item: index, section: 0))
                        }
                        
                        self.view.addItemsAt(indexPaths)
                        
                }
                self.lock.unlock()
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

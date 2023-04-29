//
//  ListPresenter.swift
//  testTask
//
//  Created by tixomark on 4/28/23.
//

import Foundation

protocol ListViewProtocol: AnyObject {
    var presenter: ListPresenterProtocol! { get }
    
    func reloadCollectionView(using items: [Item])
}

protocol ListPresenterProtocol {
    func requestItemsData()
}

extension ListPresenter: ServiceObtainableProtocol {
    var neededServices: [Service] {
        return [.router, .dataProvider, .networkService]
    }
    
    func getServices(_ services: [Service : ServiceProtocol]) {
        self.router = (services[.router] as! RouterProtocol)
        self.dataProvider = (services[.dataProvider] as! DataProviderProtocol)
        self.networkService = (services[.networkService] as! NetworkServiceProtocol)
    }
}

class ListPresenter: ListPresenterProtocol {
    var router: RouterProtocol?
    var dataProvider: DataProviderProtocol?
    var networkService: NetworkServiceProtocol?
    
    weak var view: ListViewProtocol!
    
    init(view: ListViewProtocol) {
        self.view = view
    }
    
    func requestItemsData() {
        networkService?.getItemsOn(query: "", startingFrom: 0, amount: 20, completion: { result in
            switch result {
            case .success(let items):
                self.view.reloadCollectionView(using: items)
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
}

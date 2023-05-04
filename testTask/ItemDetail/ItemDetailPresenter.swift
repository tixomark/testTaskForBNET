//
//  ItemDetailPresenter.swift
//  testTask
//
//  Created by tixomark on 4/29/23.
//

import Foundation


protocol ItemDetailViewProtocol: AnyObject {
    var presenter: ItemDetailPresenterProtocol! { get }
    
    func updateUIUsing(_ item: Item)
    func updateCategoriesIcon(_ iconUrl: String)
}

protocol ItemDetailPresenterProtocol {
    func requestDataUpdate()
    func getCategoryIcon()
}

extension ItemDetailPresenter: ServiceObtainableProtocol {
    var neededServices: [Service] {
        [.router, .networkService]
    }
    
    func getServices(_ services: [Service : ServiceProtocol]) {
        self.router = (services[.router] as! RouterProtocol)
        self.networkService = (services[.networkService] as! NetworkServiceProtocol)
    }
}

final class ItemDetailPresenter: ItemDetailPresenterProtocol {
    var router: RouterProtocol?
    var networkService: NetworkServiceProtocol?
    
    weak var view: ItemDetailViewProtocol!
    var item: Item!
    
    init(view: ItemDetailViewProtocol, item: Item) {
        self.view = view
        self.item = item
    }
    deinit {
        print("deinited ItemDetailPresenter")
    }
    
    func requestDataUpdate() {
        view.updateUIUsing(item)
    }
    
    func getCategoryIcon() {
        networkService?.downloadCategoryIconFor(item: item,
                                         completion: { result in
            switch result {
            case .success(let iconUrl):
                self.item.categories?.icon = iconUrl.absoluteString
                self.view.updateCategoriesIcon(iconUrl.absoluteString)
            case .failure(_):
                return
            }
        })
    }
}

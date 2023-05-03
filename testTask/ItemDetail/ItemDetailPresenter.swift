//
//  ItemDetailPresenter.swift
//  testTask
//
//  Created by tixomark on 4/29/23.
//

import Foundation


protocol ItemDetailViewProtocol: AnyObject {
    var presenter: ItemDetailPresenterProtocol! { get }
    
    func updateUIUsing(item: Item)
}

protocol ItemDetailPresenterProtocol {
    func requestDataUpdate()
}

extension ItemDetailPresenter: ServiceObtainableProtocol {
    var neededServices: [Service] {
        [.router, .dataProvider]
    }
    
    func getServices(_ services: [Service : ServiceProtocol]) {
        self.router = (services[.router] as! RouterProtocol)
        self.dataProvider = (services[.dataProvider] as! DataProviderProtocol)
    }
}

final class ItemDetailPresenter: ItemDetailPresenterProtocol {
    var router: RouterProtocol?
    var dataProvider: DataProviderProtocol?
    
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
        view.updateUIUsing(item: item)
    }
}

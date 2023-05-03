//
//  ModuleBuiler.swift
//  testTask
//
//  Created by tixomark on 4/28/23.
//

import Foundation

protocol ModuleBuilderProtocol {
    func createListModule() -> ListViewController
    func createItemDetailModule(item: Item) -> ItemDetailViewController
}

extension ModuleBuilder: ServiceProtocol {
    var description: String {
        return "ModuleBuilder"
    }
}

final class ModuleBuilder: ModuleBuilderProtocol {
    private var services: [Service:ServiceProtocol] = [:]
    
    init() {
        services[.dataProvider] = DataProvider()
        services[.networkService] = NetworkService()
        services[.moduleBuilder] = self
        
        let router = Router()
        injectServices(forObject: router)
        services[.router] = router
    }
    
    private func injectServices(forObject object: ServiceObtainableProtocol) {
        let neededServices = object.neededServices
        var servicesDict: [Service:ServiceProtocol] = [:]
        neededServices.forEach { service in
            servicesDict[service] = self.services[service]
        }
        object.getServices(servicesDict)
    }
    
    func getRouter() -> Router {
        return services[.router] as! Router
    }
    
    func createListModule() -> ListViewController {
        let view = ListViewController()
        let presenter = ListPresenter(view: view)
        injectServices(forObject: presenter)
        view.presenter = presenter
        
        return view
    }
    
    func createItemDetailModule(item: Item) -> ItemDetailViewController {
        let view = ItemDetailViewController()
        let presenter = ItemDetailPresenter(view: view, item: item)
        injectServices(forObject: presenter)
        view.presenter = presenter
        
        return view
    } 
}

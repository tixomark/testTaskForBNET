//
//  Router.swift
//  testTask
//
//  Created by tixomark on 4/28/23.
//

import Foundation
import UIKit

protocol RouterProtocol {
    var window: UIWindow? { get }
    
    func showListModule()
    func showItemDetailModule(item: Item)
}

extension Router: ServiceProtocol {
    var description: String {
        return "Router"
    }
}

extension Router: ServiceObtainableProtocol {
    var neededServices: [Service] {
        return  [.moduleBuilder]
    }
    
    func getServices(_ services: [Service : ServiceProtocol]) {
        self.moduleBuilder = (services[.moduleBuilder] as! ModuleBuilderProtocol)
    }
}

final class Router: RouterProtocol {
    weak var window: UIWindow?
    private var navigation: NavigationController?
    
    var moduleBuilder: ModuleBuilderProtocol?
    
    func showListModule() {
        if navigation != nil {
            window?.rootViewController = navigation
            print("showing ListModule")
        } else if let listVC = moduleBuilder?.createListModule() {
            navigation = NavigationController(rootViewController: listVC)
            print("created ListModule")
            showListModule()
        } else { print("Error while creating ListModule") }
    }
    
    func showItemDetailModule(item: Item) {
        if navigation == nil {
            print("somehow ItemDetailModule precedes ListModule")
            showListModule()
            showItemDetailModule(item: item)
        } else if let detailVC = moduleBuilder?.createItemDetailModule(item: item) {
            navigation?.pushViewController(detailVC, animated: true)
            print("showing ItemDetailModule")
        } else {
            print("Error while showing ItemDetailModule")
        }
    }
    
}

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

class Router: RouterProtocol {
    weak var window: UIWindow?
    var navigation: NavigationController?
    
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
    
    
}

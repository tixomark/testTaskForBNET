//
//  Service+Protocols.swift
//  testTask
//
//  Created by tixomark on 4/28/23.
//

import Foundation

enum Service {
    case router, moduleBuilder, networkService
}

protocol ServiceProtocol: CustomStringConvertible {
    
}

protocol ServiceObtainableProtocol {
    var neededServices: [Service] {get}
    func getServices(_ services: [Service: ServiceProtocol])
}

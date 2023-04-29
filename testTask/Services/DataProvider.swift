//
//  InternalStorage.swift
//  testTask
//
//  Created by tixomark on 4/28/23.
//

import Foundation

protocol DataProviderProtocol {
    
}

extension DataProvider: ServiceProtocol {
    var description: String {
        return "DataProvider"
    }
}

class DataProvider: DataProviderProtocol {
    
}

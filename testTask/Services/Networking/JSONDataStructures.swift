//
//  JSONDataStructures.swift
//  testTask
//
//  Created by tixomark on 4/28/23.
//

import Foundation
import UIKit

// MARK: - Item
struct Item: Codable {
    let id: Int?
    var imageURL: String?
//    let categories: Categories?
    let name, description, documentation: String?
//    let fields: [Field]?
    
    enum CodingKeys: String, CodingKey {
        case imageURL = "image"
        case id, name, description, documentation
    }
}

struct Categories: Codable {
    let id: Int?
    let icon, image, name: String?
}

struct Field: Codable {
    let typesID: Int?
    let type: TypeEnum?
    let name, value: String?
    let image: String?
    let flags: Flags?
    let show, group: Int?

    enum CodingKeys: String, CodingKey {
        case typesID = "types_id"
        case type, name, value, image, flags, show, group
    }
}

struct Flags: Codable {
    let html, noValue, noName, noImage: Int?
    let noWrap, noWrapName, system: Int?

    enum CodingKeys: String, CodingKey {
        case html
        case noValue = "no_value"
        case noName = "no_name"
        case noImage = "no_image"
        case noWrap = "no_wrap"
        case noWrapName = "no_wrap_name"
        case system
    }
}

enum TypeEnum: String, Codable {
    case image = "image"
    case list = "list"
    case text = "text"
}

// MARK: - Index
typealias ItemList = [Item]

import Cocoa

// MARK: - Item
struct Item: Codable {
    let id: Int?
    let image: String?
//    let categories: Categories?
    let name, description, documentation: String?
    let imageg: Data?
//    let fields: [Field]?
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

class NetworkService {
    private let networkQueue = DispatchQueue(label: "networkQueue", qos: .default, attributes: .concurrent)
    private var networkURLSession: URLSession!
    
    private let baseURL: String = "http://shans.d2.i-partner.ru"
    
    private enum APIMethods: String {
        case item = "/api/ppp/item/"
        case index = "/api/ppp/index/"
    }
    
    init() {
        networkURLSession = URLSession(configuration: .default)
    }
    
    func getItemBy(_ id: Int, completion: @escaping (Result<Item, Error>) -> ()) {
        var urlComponents = URLComponents(string: baseURL + APIMethods.item.rawValue)!
        urlComponents.queryItems = [URLQueryItem(name: "id", value: "\(id)")]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"

        networkURLSession.dataTask(with: request) { data, response, error in
            guard let resp = response as? HTTPURLResponse, resp.statusCode / 100 == 2 else {
                print("Bad response code")
                return
            }
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            guard let data = data else {
                print("Response does not contain data")
                return
            }
            
            do {
                let item: Item = try JSONDecoder().decode(Item.self, from: data)
                completion(.success(item))
            } catch {
                print("Error while decoding json")
            }
        }.resume()
    }
    
    func getItemsOn(query: String = "",
                  startingFrom offset: Int = 0,
                  amount limit: Int = 10,
                  completion: @escaping (Result<ItemList, Error>) -> ()) {
        
        var components = URLComponents(string: baseURL + APIMethods.index.rawValue)!
        components.queryItems = [URLQueryItem(name: "offset", value: "\(offset)"),
                                 URLQueryItem(name: "limit", value: "\(limit)"),
                                 URLQueryItem(name: "query", value: "\(query)")]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        
        networkURLSession.dataTask(with: request) { data, response, error in
            guard let resp = response as? HTTPURLResponse, resp.statusCode / 100 == 2 else {
                print("Bad response code")
                return
            }
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            guard let data = data else {
                print("Response does not contain data")
                return
            }
            
            do {
                let index: ItemList = try JSONDecoder().decode(ItemList.self, from: data)
                completion(.success(index))
            } catch {
                print("Error while decoding json")
            }
        }.resume()
        
    }
    
    private func getImage(at path: String)
    
}

let ns = NetworkService()

//ns.getItemBy(9) { result in
//    switch result {
//    case .success(let ritem):
//        item = ritem
//        print(item)
//    case .failure(let error):
//        print(error)
//    }
//}

//http://shans.d2.i-partner.ru/upload/drugs/categories//desikanti_a1057641.png

ns.getItemsOn(query: "Де") { result in
    switch result {
    case .success(let ritem):
        ritem.count
        print(ritem[0])
    case .failure(let error):
        print(error)
    }
}



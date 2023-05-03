//
//  NetworkService.swift
//  testTask
//
//  Created by tixomark on 4/28/23.
//

import Foundation

protocol NetworkServiceProtocol {
    func getItemBy(_ id: Int,
                   completion: @escaping (Result<Item, Error>) -> ())
    func getItemsOn(query: String,
                    startingFrom offset: Int,
                    amount limit: Int,
                    completion: @escaping (Result<ItemList, Error>) -> ())
    func downloadImageFor(item: Item,
                          completion: @escaping (Result<URL,Error>) -> ())
}


extension NetworkService: ServiceProtocol {
    var description: String {
        return "NetworkService"
    }
}

final class NetworkService: NetworkServiceProtocol {
    private let networkQueue = DispatchQueue(label: "networkQueue",
                                             qos: .default,
                                             attributes: .concurrent)
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
        networkQueue.async {
            var urlComponents = URLComponents(string: self.baseURL + APIMethods.item.rawValue)!
            urlComponents.queryItems = [URLQueryItem(name: "id", value: "\(id)")]
            
            var request = URLRequest(url: urlComponents.url!)
            request.httpMethod = "GET"
            
            self.networkURLSession.dataTask(with: request) { [unowned self] data, response, error in
                guard validateResponse(data, response, error) else {
                    completion(.failure(error!))
                    return
                }
                
                do {
                    let item: Item = try JSONDecoder().decode(Item.self, from: data!)
                    completion(.success(item))
                } catch {
                    print("Error while decoding json")
                }
            }.resume()
        }
    }
    
    func getItemsOn(query: String = "",
                    startingFrom offset: Int = 0,
                    amount limit: Int = 10,
                    completion: @escaping (Result<ItemList, Error>) -> ()) {
        
        networkQueue.async {

            var components = URLComponents(string: self.baseURL + APIMethods.index.rawValue)!
            components.queryItems = [URLQueryItem(name: "offset", value: "\(offset)"),
                                     URLQueryItem(name: "limit", value: "\(limit)"),
                                     URLQueryItem(name: "query", value: "\(query)")]
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            
            self.networkURLSession.dataTask(with: request) { [unowned self] data, response, error in
                guard validateResponse(data, response, error) else {
                    completion(.failure(error!))
                    return
                }
                
                do {
                    let index: ItemList = try JSONDecoder().decode(ItemList.self, from: data!)
                    completion(.success(index))
                } catch {
                    print("Error while decoding json")
                }
            }.resume()
        }
    }
    
    func downloadImageFor(item: Item, completion: @escaping (Result<URL,Error>) -> ()) {
        networkQueue.async {
            guard let imagePath = item.imageURL,
                  let imageURL = URLComponents(string: self.baseURL + imagePath)?.url else {
                print("Item does not contain image")
                return
            }
            
            self.networkURLSession.downloadTask(with: imageURL) { tempURL, response, error in
                guard error == nil, let tempURL = tempURL else {
                    completion(.failure(error!))
                    print(error!.localizedDescription)
                    return
                }
                
                guard let newImageURL = URLComponents(string: FileManager.default.imagesDir.absoluteString + imageURL.lastPathComponent)?.url else { return }
                if FileManager.default.fileExists(atPath: newImageURL.path) {
                    completion(.success(newImageURL))
                } else {
                    do {
                        try FileManager.default.moveItem(at: tempURL, to: newImageURL)
                        completion(.success(newImageURL))
                    } catch {
                        print("Can not move image at \(tempURL) to \(newImageURL)")
                    }
                }
            }.resume()
        }
    }
    
    private func validateResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Bool {
        guard error == nil else {
            print(error!.localizedDescription)
            return false
        }
        guard let resp = response as? HTTPURLResponse, resp.statusCode / 100 == 2 else {
            print("Bad response code")
            return false
        }
        guard data != nil else {
            print("Response does not contain data")
            return false
        }
        return true
    }
}

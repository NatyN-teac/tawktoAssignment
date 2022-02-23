//
//  NetworkApiService.swift
//  tawkto
//
//  Created by mac on 06/02/2022.
//

import Foundation
import CoreData

enum NetworkError: Error {
   
    case transportError(Error)
    case serverError(statusCode: Int)
    case noData
    case decodingError
}

class NetworkApiService {
    
    static let shared = NetworkApiService()
    
    
    let urlSession = URLSession(configuration: URLSessionConfiguration.default)
    var isPaginating = false
    var dbHelper: DBHelper = DBHelper()
    
    func performFetch<T:Codable>(url: URL, completion: @escaping (Result<T,NetworkError>) -> Void) {
        urlSession.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(.transportError(error)))
                return
            }
            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                completion(.failure(.serverError(statusCode: response.statusCode)))
                return
            }
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let users = try JSONDecoder().decode(T.self, from: data)
                completion(.success(users))
            }catch {
                completion(.failure(.decodingError))
            }
            
            if self.isPaginating {
                self.isPaginating = false
            }
        }).resume()
    }
    
    func fetchUserDataFromApi(since: Int, pageSize: Int?, isPagingEnabled: Bool? = false,completion: @escaping (Result<[User],NetworkError>) -> Void){
       
        if let _ = isPagingEnabled{
            isPaginating = true
        }
        if let url = URL(string: ApiAddress.getURL(since: since, pageSize: pageSize)) {
            urlSession.dataTask(with: url, completionHandler: { data, response, error in
               
                if let error = error {
                    completion(.failure(.transportError(error)))
                    return
                }
                if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                    completion(.failure(.serverError(statusCode: response.statusCode)))
                    return
                }
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let users = try JSONDecoder().decode([User].self, from: data)
                    completion(.success(users))
                }catch {
                    completion(.failure(.decodingError))
                }
                
                if self.isPaginating {
                    self.isPaginating = false
                }
               
            }).resume()
        }
    }
    
    
    func fetchProfileDataFromServer(url: String,completion:@escaping (Result<UserDetailProfile,NetworkError>) -> Void){
        let urlAddress = URL(string: url)
        if let newUrl = urlAddress {
            
            
            urlSession.dataTask(with: newUrl, completionHandler: { data, response, error in
                if let error = error {
                    print("errror : \(error)")
                    completion(.failure(.transportError(error)))
                    return
                }
                if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                    completion(.failure(.serverError(statusCode: response.statusCode)))
                    return
                }
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                
                    let userProfile = try JSONDecoder().decode(UserDetailProfile.self, from: data)
                    completion(.success(userProfile))
                }catch {
                    print("error in decoding: \(error.localizedDescription)")
                    completion(.failure(.decodingError))
                }
                
            }).resume()
        }
        
        
    }
    
   
}

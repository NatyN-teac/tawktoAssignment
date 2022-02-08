//
//  Resources.swift
//  tawkto
//
//  Created by mac on 06/02/2022.
//

import Foundation

struct ApiAddress {
    static let BASE_URL = "https://api.github.com/"
    
    static func getURL(since: Int = 0, pageSize: Int?) -> String{
        if let pageSize = pageSize {
            return "\(BASE_URL)users?since=\(since)&per_page=\(pageSize)"
        }else {
            return "\(BASE_URL)users?since=\(since)"
        }
       
    }
}

//
//  User.swift
//  tawkto
//
//  Created by mac on 04/02/2022.
//

import Foundation

struct User: Codable {
    var username: String
    var id: Int
    var profileDetail: String
    var profileImageUrl: String
    
    
    enum CodingKeys: String, CodingKey {
        case username = "login"
        case id
        case profileDetail = "url"
        case profileImageUrl = "avatar_url"
        
    }
}

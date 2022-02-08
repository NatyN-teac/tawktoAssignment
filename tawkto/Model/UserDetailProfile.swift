//
//  UserProfile.swift
//  tawkto
//
//  Created by mac on 08/02/2022.
//

import Foundation

struct UserDetailProfile: Codable {
    var id: Int
    var name: String
    var username: String
    var company: String
    var blog: String
    var following: Int
    var follower: Int
    var location: String
    var profileUrl: String
    
    enum CodingKeys: String,CodingKey {
        case id
        case name = "name"
        case company = "company"
        case blog = "blog"
        case username = "login"
        case follower = "followers"
        case following = "following"
        case location = "location"
        case profileUrl = "avatar_url"
    }
}

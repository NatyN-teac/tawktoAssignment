//
//  MapperUserModel.swift
//  tawkto
//
//  Created by mac on 07/02/2022.
//

import Foundation


struct MapperUserModel: Hashable {
    var id: Int
    var username: String
    var profileURL: String
    var detail: String
    var hasNote: Bool
}

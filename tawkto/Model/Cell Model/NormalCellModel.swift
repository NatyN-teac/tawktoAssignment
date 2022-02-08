//
//  NormalCellModel.swift
//  tawkto
//
//  Created by mac on 06/02/2022.
//

import UIKit

struct NormalCellModel: TableViewModelDataProtocol {
    var user: User
    
    var cellIdentifier: String = "NormalTableViewCell"
    var username: String
    var imageURL: String
    var detail: String
    
    init(username: String,imageURL: String, detail: String,user: User) {
        self.username = username
        self.imageURL = imageURL
        self.detail = detail
        self.user = user
    }
    
    
}

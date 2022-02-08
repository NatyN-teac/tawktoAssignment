//
//  InvertedCellModel.swift
//  tawkto
//
//  Created by mac on 06/02/2022.
//

import Foundation

struct InvertedCellModel: TableViewModelDataProtocol {
    var cellIdentifier: String = "InvertedTableViewCell"
    var username: String
    var imageURL: String
    var detail: String
    var user: User
    
    init(username: String, imageURL: String, detail: String,user: User){
        self.username = username
        self.imageURL = imageURL
        self.detail = detail
        self.user = user
    }
}

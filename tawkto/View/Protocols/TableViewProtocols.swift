//
//  TableViewCellModelDataProtocol.swift
//  tawkto
//
//  Created by mac on 06/02/2022.
//

import Foundation

protocol TableViewModelDataProtocol {
    var cellIdentifier: String { get }
    var user: User {get set}
}

protocol TableViewCellProtocol {
    
    func pupulateData(withData data: TableViewModelDataProtocol)
}



//
//  InvertedTableViewCell.swift
//  tawkto
//
//  Created by mac on 06/02/2022.
//

import UIKit

class InvertedTableViewCell: UITableViewCell {

    @IBOutlet var imageBgView: CircularView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var usernameLbl: UILabel!
    @IBOutlet var detailLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImage.layer.cornerRadius = profileImage.layer.bounds.height / 2
    } 
}

extension InvertedTableViewCell: TableViewCellProtocol {
    func pupulateData(withData data: TableViewModelDataProtocol) {
        if let data = data as? InvertedCellModel {
            self.usernameLbl.text = data.username
            self.detailLbl.text = data.detail
            self.imageBgView.backgroundColor = .black
            self.profileImage.loadImageUsingCache(withUrl:data.imageURL)
        }
    }
    
    
}

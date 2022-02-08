//
//  NoteTableViewCell.swift
//  tawkto
//
//  Created by mac on 06/02/2022.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var usernameLbl: UILabel!
    @IBOutlet var detailLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = profileImageView.layer.bounds.height / 2
    }
}

extension NoteTableViewCell: TableViewCellProtocol {
    func pupulateData(withData data: TableViewModelDataProtocol) {
        if let data = data as? NoteCellModel {
            self.usernameLbl.text = data.username
            self.detailLbl.text = data.detail
            self.profileImageView.loadImageUsingCache(withUrl:data.imageURL)
        }
    }
    
    
}

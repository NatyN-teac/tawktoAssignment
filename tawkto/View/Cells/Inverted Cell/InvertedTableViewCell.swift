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
    private var task: URLSessionDataTask?
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = profileImage.layer.bounds.height / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        task = nil
        profileImage.image = nil
    }
   
}

extension InvertedTableViewCell: TableViewCellProtocol {
    func pupulateData(withData data: TableViewModelDataProtocol) {
        if let data = data as? InvertedCellModel {
            self.usernameLbl.text = data.username
            self.detailLbl.text = data.detail
            if task == nil {
                task =  self.profileImage.loadImageUsingCache(withUrl:data.imageURL,isInverted: true)
            }
        }
    }
    
    
}



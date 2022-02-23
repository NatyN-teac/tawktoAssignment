//
//  NormalTableViewCell.swift
//  tawkto
//
//  Created by mac on 06/02/2022.
//

import UIKit

class NormalTableViewCell: UITableViewCell {
    @IBOutlet var userProfileImage: UIImageView!
    @IBOutlet var detailLbl: UILabel!
    @IBOutlet var usernameLbl: UILabel!
    @IBOutlet var holderView: CircularView!
    private var task: URLSessionDataTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        holderView.clipsToBounds = true
        userProfileImage.layer.cornerRadius = userProfileImage.layer.bounds.height / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        task = nil
        userProfileImage.image = nil
    }
    
}

extension NormalTableViewCell: TableViewCellProtocol {
    func pupulateData(withData data: TableViewModelDataProtocol) {
        if let data = data as? NormalCellModel {
            self.usernameLbl.text = data.username
            self.detailLbl.text = data.detail
            if task == nil {
                task =  self.userProfileImage.loadImageUsingCache(withUrl:data.imageURL)
            }
        }
    }
    
    
}




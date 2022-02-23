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
    private var task: URLSessionDataTask?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = profileImageView.layer.bounds.height / 2
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        task = nil
        profileImageView.image = nil
    }
}

extension NoteTableViewCell: TableViewCellProtocol {
    func pupulateData(withData data: TableViewModelDataProtocol) {
        if let data = data as? NoteCellModel {
            self.usernameLbl.text = data.username
            self.detailLbl.text = data.detail
            if task == nil {
                task = self.profileImageView.loadImageUsingCache(withUrl:data.imageURL)
            }
            
        }
    }
    
    
}

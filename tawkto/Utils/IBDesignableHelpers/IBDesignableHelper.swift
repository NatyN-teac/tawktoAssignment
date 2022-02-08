//
//  IBDesignableHelper.swift
//  tawkto
//
//  Created by mac on 06/02/2022.
//

import UIKit

@IBDesignable
class CircularView: UIView {
    
    @IBInspectable
    var height: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = height / 2
        }
    }
    @IBInspectable
    var borderLineWidth: Double = 0 {
        didSet {
            self.layer.borderWidth = borderLineWidth
        }
    }
    
    @IBInspectable
    var borderLineColor: UIColor = .systemGray {
        didSet {
            self.layer.borderColor = borderLineColor.cgColor
        }
    }
    
    
    
}

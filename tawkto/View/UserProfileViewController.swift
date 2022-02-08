//
//  UserProfileViewController.swift
//  tawkto
//
//  Created by mac on 08/02/2022.
//

import UIKit

class UserProfileViewController: UIViewController {
    var userProfileVM: UserProfileViewModel!
    @IBOutlet var coverImage: UIImageView!
    
    @IBOutlet var sucessMessage: UILabel!
    @IBOutlet var followers: UILabel!
    @IBOutlet var followings: UILabel!
    @IBOutlet var usernameLbl: UILabel!
    @IBOutlet var companyLbl: UILabel!
    @IBOutlet var blogLbl: UILabel!
    @IBOutlet var noteTextView: UITextView!
    
    
    
    var indicatorView: UIView?
    var userProfile: UserProfileMapperModel?
    func loadingView(isLoading: Bool) {
        indicatorView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        let indicator = UIActivityIndicatorView()
        indicator.color = .orange
        if #available(iOS 13.0, *) {
            indicator.style = .large
        } else {
            // Fallback on earlier versions
        }
        
        indicatorView!.tag = 1001
        indicatorView!.backgroundColor = .white
        indicatorView!.addSubview(indicator)
        indicator.startAnimating()
        indicator.center = indicatorView!.center
        
        if isLoading {
            self.view.addSubview(indicatorView!)
        }else {
            self.view.subviews.forEach { v in
                if v.tag == 1001 {
                    v.removeFromSuperview()
                }
            }
            
            
        }
    }
    
    
    func errorView(isLoading:Bool){
        let holderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        holderView.tag = 1002
        holderView.backgroundColor = .white
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        lbl.text = "No Saved profile data found!"
        lbl.textColor = .red
        holderView.addSubview(lbl)
        lbl.center = holderView.center
        lbl.textAlignment = .center
        if isLoading {
            self.view.addSubview(holderView)
        }else {
            self.view.subviews.forEach { v in
                if v.tag == 1002 {
                    v.removeFromSuperview()
                }
                
            }
        }
       
    }
    
    @objc func keyboardWillHide() {
        self.view.frame.origin.y = 0
    }

    @objc func keyboardWillChange(notification: NSNotification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if noteTextView.isFirstResponder {
                self.view.frame.origin.y = -keyboardSize.height
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.userProfileVM.isLoading.bind { val in
            DispatchQueue.main.async {
                self.loadingView(isLoading: val)
            }
            
            
        }
        
        self.userProfileVM.userProfile.bind { result in
            if !result.isEmpty {
                let value = result[0]
                self.userProfile = value
                DispatchQueue.main.async {
                    self.title = value.username
                    self.coverImage.loadImageUsingCache(withUrl: value.profileUrl)
                    self.followers.text = "\(value.follower)"
                    self.followings.text = "\(value.following)"
                    self.usernameLbl.text = value.name
                    self.blogLbl.text = value.blog
                    self.companyLbl.text = value.company
                    self.noteTextView.text = value.note
                    
                }
            }
            
        }
        self.userProfileVM.errorOnLoading.bind { val in
            DispatchQueue.main.async {
                self.errorView(isLoading: val)
            }
        }
        
        self.userProfileVM.successMessage.bind { value in
            DispatchQueue.main.async {
                if !value.isEmpty {
                    self.sucessMessage.isHidden = false
                    self.sucessMessage.text = value
                }else {
                    self.sucessMessage.isHidden = true
                }
            }
          
            
        }
    }
    
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        if let text = noteTextView.text,let userProfile = self.userProfile  {
            self.userProfileVM.saveNote(id: userProfile.id, note: text)
        }
        
    }
    
}

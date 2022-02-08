//
//  ViewController.swift
//  tawkto
//
//  Created by mac on 04/02/2022.
//

import UIKit

class UserListViewController: UIViewController, UISearchBarDelegate {
    
    
    var userListViewModel: UserListViewModel!
    private let INTERNET_INDICATOR_VIEW_TAG = 1000
    private let NO_INTERNET_NO_DATA = 999
    var users: [TableViewModelDataProtocol] = []
    var activityIndicator = UIActivityIndicatorView()
    var isLoadingData: Bool?
    {
        didSet {
            if (isLoadingData ?? true) && inPaginationMode != true {
                self.activityIndicator.startAnimating()
            }else {
                self.activityIndicator.stopAnimating()
            }
            
        }
    }
    var pageSize: Int?
    var lastId: Int?
    var isConnected = false
    var isPagination: Bool? {
        didSet {
            if isPagination ?? false {
                self.userListTableView.tableFooterView = createFooterSpinner()
            }else {
                self.userListTableView.tableFooterView = nil
            }
        }
    }
    
    var inPaginationMode: Bool? {
        didSet {
            if inPaginationMode ?? false {
                self.userListTableView.tableFooterView = createFooterSpinner()
            }else {
                self.userListTableView.tableFooterView = nil
            }
        }
    }
    var isInSearchMode: Bool! = false
    
    @IBOutlet var userListTableView: UITableView!
    func setupTableView(){
        userListTableView?.delegate = self
        userListTableView?.dataSource = self
        registerNib()
    }
    
    func registerNib(){
        userListTableView.register(nibName: "NormalTableViewCell")
        userListTableView.register(nibName: "NoteTableViewCell")
        userListTableView.register(nibName: "InvertedTableViewCell")
    }
    var searchController: UISearchController!
    let searchBar = UISearchBar()
    func searchBarUI(){
        searchBar.frame = CGRect(x: 0, y: 0, width: 200, height: 70)
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = " Search Here....."
        searchBar.sizeToFit()
        userListTableView.tableHeaderView = searchBar
    }
    
    var selectedUserProfileUrl:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        navigationController?.navigationBar.isHidden = true
        searchBarUI()
        
        self.view.addSubview(activityIndicator)
        activityIndicator.center = self.view.center
        activityIndicator.color = .orange
        activityIndicator.style = .large
         
        //Listeners from VM
        userListViewModel.isLoading.bind {[weak self] value in
            DispatchQueue.main.async {
                self?.isLoadingData = value
            }
            
        }
        activityIndicator.startAnimating()
        userListViewModel.usersList.bind { [weak self] users in
            DispatchQueue.main.async {
                self?.pageSize = users.count
                self?.users.append(contentsOf: users)
                self?.userListTableView.reloadData()
                
                
            }
        }
        userListViewModel.isPaginationLoading.bind { val in
            DispatchQueue.main.async {
                self.isPagination = val
            }
        }
        userListViewModel.lastSinceId.bind { id in
            DispatchQueue.main.async {
                self.lastId = id
            }
            
        }
        userListViewModel.isInPaginateMode.bind { inpagination in
            DispatchQueue.main.async {
                self.inPaginationMode = inpagination
            }
        }
        
        userListViewModel.searchResult.bind { result in
            DispatchQueue.main.async {
                self.isInSearchMode = self.searchBar.text != nil
                if !result.isEmpty && self.isInSearchMode {
                    self.users = result
                    self.userListTableView.reloadData()
                }
                
            }
        }
        
        userListViewModel.isConnected.bind { isConnected in
            DispatchQueue.main.async {
                self.requestData(isConn: isConnected)
            }
        }
    }
    
    
    func requestData(isConn: Bool){
        self.isConnected = isConn
        if  isConn {
            self.users = []
            self.removeViewFromSuperview()
            self.removeViewFromSuperviewOfNoInternet()
            self.userListViewModel.apiServiceManager.isPaginating = false
            self.userListViewModel.retrieveData(since: 0, size: self.pageSize)
        }else {
            self.userListViewModel.getData(since: 0, size: self.pageSize)
            if self.userListViewModel.usersList.value.isEmpty {
                self.activityIndicator.stopAnimating()
                self.view.bringSubviewToFront(self.createNoInternetNoDataStateView())
            }else {
                self.activityIndicator.stopAnimating()
                self.removeViewFromSuperviewOfNoInternet()
                self.view.bringSubviewToFront(self.createInternetIndicator())
                self.userListTableView.reloadData()
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !self.users.isEmpty {
            self.requestData(isConn: self.isConnected)
        }
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.users = []
        searchBar.text = ""
        searchBar.endEditing(true)
        self.userListViewModel.retrieveData(since: 0, size: pageSize)
        self.userListTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.userListViewModel.search(searchText: searchText)
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let term = searchBar.text {
            self.userListViewModel.search(searchText: term)
        }
        searchBar.text = ""
    }
    
    
    private func createNoInternetNoDataStateView() -> UIView{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 200))
        view.tag = NO_INTERNET_NO_DATA
        let image = UIImageView(image: UIImage(named: "nodata.png"))
        image.center = view.center
        view.addSubview(image)
        self.view.addSubview(view)
        return view
        
    }
    
    private func createInternetIndicator() -> UIView{
        let showNoInternetView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 70))
        showNoInternetView.tag = INTERNET_INDICATOR_VIEW_TAG
        showNoInternetView.backgroundColor = .red
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: showNoInternetView.bounds.width, height: 30))
        label.text = "Your are not Connected to Internet"
        label.center = showNoInternetView.center
        label.textColor = .white
        showNoInternetView.addSubview(label)
        // create button to dismiss the message pop up
        let closeBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        closeBtn.backgroundColor = .clear
        closeBtn.setImage(UIImage(named: "cancel.png"), for: .normal)
        closeBtn.center.x = showNoInternetView.bounds.width - 20
        closeBtn.center.y = showNoInternetView.center.y
        
        closeBtn.addTarget(self, action: #selector(closeBtnPressed(_:)), for: .touchUpInside)
        showNoInternetView.addSubview(closeBtn)
        self.view.addSubview(showNoInternetView)
        showNoInternetView.center.y = self.view.bounds.height - 30
        return showNoInternetView
    }
    
    @objc func closeBtnPressed(_ sender: UIButton) {
        self.removeViewFromSuperview()
    }
    
    func removeViewFromSuperview(){
        self.view.subviews.forEach { v in
            if v.tag == INTERNET_INDICATOR_VIEW_TAG {
                v.removeFromSuperview()
            }
        }
    }
    func removeViewFromSuperviewOfNoInternet(){
        self.view.subviews.forEach { v in
            if v.tag == NO_INTERNET_NO_DATA {
                v.removeFromSuperview()
            }
        }
    }
    
    
    private func createFooterSpinner() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.color = .orange
        if #available(iOS 13.0, *) {
            spinner.style =  .large
        } else {
            // Fallback on earlier versions
        }
        spinner.backgroundColor = .black
        spinner.center = footerView.center
        spinner.startAnimating()
        footerView.addSubview(spinner)
        
        return footerView
        
    }
    
    //Segue and Dependency Injection for Next Screen.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedProfile = self.selectedUserProfileUrl else {return}
        if segue.identifier == K.SegueName.ToProfile {
            guard let destination = segue.destination as? UserProfileViewController else {return}
            
            let storyboard = UIStoryboard(name: K.StoryboardID.Main, bundle: .main)
            let navController = storyboard.instantiateInitialViewController() as! UINavigationController
            navigationController?.navigationBar.isHidden = false
            let userProfileVM = UserProfileViewModel(apiServiceManager: NetworkApiService(), url: selectedProfile.profileDetail,dbService: DbService(helper: DBHelper()),isConnected: self.isConnected,id: selectedProfile.id)
            destination.userProfileVM = userProfileVM
            navController.present(destination, animated: true, completion: nil)
        }
    }
    
}

//MARK: -UITableViewDataSource
extension UserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !users.isEmpty else {return UITableViewCell()}
        let cellModel = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellModel.cellIdentifier) as? TableViewCellProtocol
      
        cell?.pupulateData(withData: cellModel)
        
        return cell as? UITableViewCell ?? UITableViewCell()
        
    }
    
    
}

//MARK: -UITableViewDelegate
extension UserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedUserProfileUrl = self.users[indexPath.row].user
        performSegue(withIdentifier: K.SegueName.ToProfile, sender: self)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

//MARK: -UIScrollViewDelegate
extension UserListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if (position > (userListTableView.contentSize.height - scrollView.frame.size.height)) && (isConnected) {
            userListViewModel.isInPaginateMode.value = true
            userListViewModel.retrieveData(since: lastId!, size: pageSize)
        }
    }
}

extension UserListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let term = searchBar.text {
            self.userListViewModel.search(searchText: term)
        }
    }
    
    
}

extension UITableView {
    func register(nibName: String) {
        register(nibName: nibName, withReuseCellIdentifier: nibName)
    }
    func register(nibName: String, withReuseCellIdentifier: String) {
        let nib = UINib(nibName: nibName, bundle: .main)
        register(nib, forCellReuseIdentifier: withReuseCellIdentifier)
    }
}



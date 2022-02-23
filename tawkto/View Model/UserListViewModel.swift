//
//  UserListViewModel.swift
//  tawkto
//
//  Created by mac on 06/02/2022.
//

import Foundation

class UserListViewModel {
    
    var apiServiceManager: NetworkApiService!
    var dbServiceManager: DbService!
    var network: NetworkMonitorVM!
    
    var numberOfItems = DynamicBox<Int>(0)
    var usersList = DynamicBox<[TableViewModelDataProtocol]>([])
    var isLoading = DynamicBox<Bool>(false)
    var lastSinceId = DynamicBox<Int>(0)
    var isPaginationLoading = DynamicBox<Bool>(false)
    var isInPaginateMode = DynamicBox<Bool>(false)
    
    var isConnected = DynamicBox<Bool>(false)
    var mappedUser = DynamicBox<[MapperUserModel]>([])
    var doesDbContainData = DynamicBox<Bool>(false)
    var searchResult = DynamicBox<[TableViewModelDataProtocol]>([])
    
    var rawUserList:[User] = []
    var myPageSize = DynamicBox<Int>(0)
    
    
    //MARK: -initialize
    init(serviceManager: NetworkApiService,networkMonitor: NetworkMonitorVM,dbService: DbService){
        self.apiServiceManager = serviceManager
        self.network = networkMonitor
        self.dbServiceManager = dbService
        isConnected = network.isActive
//        self.retrieveData(since: lastSinceId.value,size: nil)
        
    }
    
    //MARK: -get locally saved data and assign to observer
    func getData(since: Int, size: Int?){
        let result = dbServiceManager.fetchUserData(since: since, pageSize: size)
        guard  !result.isEmpty else {
            self.doesDbContainData.value = false
            return
        }
        
        let resultMapped = result.map { userInDB in
            mapUserToMappedUser(user: User(username: userInDB.username!, id: Int(userInDB.id), profileDetail: userInDB.detail!, profileImageUrl: userInDB.profileURL!),hasNote: userInDB.note != nil)
        }
        self.usersList.value = mapMyData(data: resultMapped)
    }
    
    //MARK: -Search from local db
    func search(searchText: String){
        var users: [TableViewModelDataProtocol] = []
       let result = dbServiceManager.searchDataInDb(searchTerm: searchText)
        guard !result.isEmpty else {
             self.searchResult.value = []
            return
        }
        let mappedResult = result.map { userInDB in
            mapUserToMappedUser(user: User(username: userInDB.username!, id: Int(userInDB.id), profileDetail: userInDB.detail!, profileImageUrl: userInDB.profileURL!),hasNote: userInDB.note != nil)
        }
        users = mapMyData(data: mappedResult)
        self.searchResult.value = users
    }
    
    
    //MARK: -fetch data from remote server
    func retrieveData(since: Int, size: Int?) {
        isLoading.value = true
        guard !self.apiServiceManager.isPaginating else {
            return
        }
       
        let semaphore = DispatchSemaphore(value: 1)
        let concurrent = DispatchQueue(label: "concurrent",qos:.default ,attributes: .concurrent,autoreleaseFrequency: .inherit)
        concurrent.async{
            self.apiServiceManager.fetchUserDataFromApi(since: since, pageSize: size,isPagingEnabled: self.isInPaginateMode.value) { result in
                self.isLoading.value = false
                self.isPaginationLoading.value = false
                switch result {
                case .success(let users):
                    let context = self.dbServiceManager.dbHelper.backgroundContext
                    context.perform {
                        let userExistInDb = self.dbServiceManager.dbHelper.fetch(UserInDb.self,context: context)
                        users.forEach { singleUser in
                            self.dbServiceManager.storeItem(userExistInDb: userExistInDb, singleUser: singleUser,context: context)
                        }
                        do{
                            try context.save()
                        }catch {
                            print("error: \(error)")
                        }
                    }
                    self.numberOfItems.value = users.count
                    self.lastSinceId.value = users.last!.id
//                    print("Total Users: \(users.count)")
//                    print("USER: \(users.first?.username)")
                    if self.myPageSize.value == 0 {
                        self.myPageSize.value = self.rawUserList.isEmpty ? users.count : self.rawUserList.count
                    }
                    
                    
                    self.rawUserList.append(contentsOf: users)
                    self.usersList.value = self.prepareAndMapData(usersData: self.rawUserList,since: since,pageSize:size)
                    semaphore.signal()
                   
                case .failure(let err):
                    print("error: \(err)")
                    self.isLoading.value = false
                    self.isPaginationLoading.value = false
                    semaphore.signal()
                    
                }
            }
        }
        
        
    }
    
    //MARK: -map User type to MapperUserModel type
    func mapUserToMappedUser(user: User,hasNote:Bool) -> MapperUserModel {
        return MapperUserModel(id: user.id, username: user.username, profileURL: user.profileImageUrl, detail: user.profileDetail, hasNote: hasNote)

    }
    
    
    //MARK: -map user to tableview model protocol to prepare data for tableview.
    func mapMyData(data: [MapperUserModel]) -> [TableViewModelDataProtocol]{
        var tbUserData: [TableViewModelDataProtocol] = []
       
        _ = data.enumerated().map { (index,user) in
           
            let newUser = User(username: user.username, id: user.id, profileDetail: user.detail, profileImageUrl: user.profileURL)
            if((index + 1) % 4 == 0 && (index + 1) > 0){

//                print("INDEX: = \(index + 1)")
                tbUserData.append(InvertedCellModel(username: user.username, imageURL: user.profileURL, detail: user.detail,user: newUser))
            }else if user.hasNote == true {
                tbUserData.append(NoteCellModel(username: user.username, imageURL: user.profileURL, detail: user.detail,user: newUser))
            }
            else {
                tbUserData.append( NormalCellModel(username: user.username, imageURL: user.profileURL, detail: user.detail,user: newUser)
                )
                
            }
        }
        
        
        return tbUserData
    }
    
    //MARK: -check both local and remote for note existence and then map to required protocol using the above helper mapper function.
    func prepareAndMapData(usersData: [User],since: Int, pageSize: Int?) -> [TableViewModelDataProtocol]{
//        var users: [TableViewModelDataProtocol] = []
        var uniqueCollection:[MapperUserModel] = []
        uniqueCollection = usersData.map { user in
            MapperUserModel(id: user.id, username: user.username, profileURL: user.profileImageUrl, detail: user.profileDetail, hasNote: false)
        }
        
        let data = dbServiceManager.fetchUserData(since: since, pageSize: pageSize)
       data.map { userInDb in
            let mp = MapperUserModel(id: Int(userInDb.id), username: userInDb.username!, profileURL: userInDb.profileURL!, detail: userInDb.detail!, hasNote: true)
           uniqueCollection.forEach { mappedUser in
               if mappedUser.id == Int(userInDb.id) && userInDb.note != nil {
                   let index = uniqueCollection.firstIndex(of: mappedUser)
                   uniqueCollection[index!] = mp
               }
           }
           
        }
        
//        print("how many rows are there... \(uniqueCollection.count)")
//        print("orignal: \(usersData.count)")
        return mapMyData(data: uniqueCollection)
        
       
       
    }
}

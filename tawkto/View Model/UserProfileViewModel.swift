//
//  UserProfileViewModel.swift
//  tawkto
//
//  Created by mac on 08/02/2022.
//

import Foundation
import CoreData

class UserProfileViewModel {
    let apiServiceManager: NetworkApiService!
    var dbServiceManager: DbService!
    let url: String!
    let id: Int
    let isConnected: Bool!
    var userProfile = DynamicBox<[UserProfileMapperModel]>([])
    var errorOnLoading = DynamicBox<Bool>(false)
    var isLoading = DynamicBox<Bool>(false)
    var successMessage = DynamicBox<String>("")
    
    //MARK: -initialize
    init(apiServiceManager: NetworkApiService,url: String,dbService: DbService,isConnected: Bool,id: Int){
        self.apiServiceManager = apiServiceManager
        self.url = url
        self.id = id
        self.dbServiceManager = dbService
        self.isConnected = isConnected
        if isConnected {
            self.fetchDataFromRemote(url: url)
        }else {
            let result = fetchFromDb(id: id)
            guard let res = result else {
                self.errorOnLoading.value = true
                return
            }
            self.convertToUserProfileData(user: res)
        }
    }
    
    //MARK: -Save note to database.
    func saveNote(id: Int,note: String) {
        let result = self.dbServiceManager.fetchSingleUserById(id:id)
        if  result.id == id {
            let context = self.dbServiceManager.dbHelper.backgroundContext
            context.perform {
                result.note = note
                do{
                    try self.dbServiceManager.dbHelper.context.save()
                    self.successMessage.value = "Note Successfully Saved!"
                }catch {
                    print("error: \(error)")
                }
            }
             
        }
    }
    
    //MARK: -Fetch data from db by Id
    func fetchFromDb(id: Int) -> UserInDb? {
        let result = self.dbServiceManager.fetchSingleUserById(id:id)
        return result
        
    }
    
    func convertToUserProfileData(user: UserInDb?){
        self.userProfile.value = []
        guard let u = user, let name = u.name,
        let comp = u.company,
        let usernm = u.username,
        let blg = u.blog else {
            self.errorOnLoading.value = true
            return}
        let newUserProfile = UserProfileMapperModel(id: Int(u.id), name: name, username: usernm, profileUrl: u.profileURL!, company: comp, blog: blg, following: Int(u.following), follower: Int(u.follower), note: u.note ?? "")
        self.userProfile.value.append(newUserProfile)
    }
    
    //MARK: -fetch data from Remove server
    func fetchDataFromRemote(url: String){
        isLoading.value = true
        apiServiceManager.fetchProfileDataFromServer(url: url) { result in
            switch result {
            case .success(let userProfile):
                self.isLoading.value = false
                let result = self.dbServiceManager.fetchSingleUserById(id:userProfile.id)
                if result.note != nil  {
                    let newUserProfile = UserProfileMapperModel(id: Int(userProfile.id), name: userProfile.name, username: userProfile.username, profileUrl: userProfile.profileUrl, company: userProfile.company, blog: userProfile.blog, following: userProfile.following, follower: userProfile.follower, note: result.note!)
                    self.userProfile.value.append(newUserProfile)
                }else {
                    let newUserProfile = UserProfileMapperModel(id:Int(userProfile.id),name: userProfile.name, username: userProfile.username, profileUrl: userProfile.profileUrl, company: userProfile.company, blog: userProfile.blog, following: userProfile.following, follower: userProfile.follower, note: "")
                    self.userProfile.value.append(newUserProfile)
                    
                }
                
                //MARK: -Save data in background to db
                let ctx = self.dbServiceManager.dbHelper.backgroundContext
                ctx.perform {
                    ctx.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
                    result.follower = Int64(userProfile.follower)
                    result.following = Int64(userProfile.following)
                    result.blog = userProfile.blog
                    result.company = userProfile.company
                    result.name = userProfile.name
                    do{
                        try ctx.save()
                    }catch {
                        print("error: \(error)")
                    }
                }         
                
            case .failure(let error):
                self.isLoading.value = false
                print("error is going on: \(error.localizedDescription)")
                self.errorOnLoading.value = true
                
            }
        }
    }
}

//
//  DbService.swift
//  tawkto
//
//  Created by mac on 07/02/2022.
//

import Foundation
import CoreData

class DbService {
    let dbHelper: DBHelper!
    
    init(helper: DBHelper){
        self.dbHelper = helper
    }
    func fetchSingleUserById(id: Int) -> UserInDb{
        let request = UserInDb.fetchRequest()
        let predicate = NSPredicate(format: "id == \(id)")
        request.predicate = predicate
        
        do {
            let result = try self.dbHelper.context.fetch(request)
            return result[0]
        }catch {
            print("error: \(error.localizedDescription)")
            return [][0]
        }
    }
    
    func fetchUserData(since: Int, pageSize: Int?) -> [UserInDb]{
        let request = UserInDb.fetchRequest()
        do{
            let sort = NSSortDescriptor(key: "id", ascending: true)
            request.sortDescriptors = [sort]
            request.fetchOffset = since
            if pageSize != nil {
                
                request.fetchLimit = pageSize!
            }
            let resultData = try self.dbHelper.context.fetch(request)
            return resultData
        }catch {
            print("error during loading data: \(error.localizedDescription)")
            return []
        }
    }
    
    func hasDataInDb() -> Bool {
        let request = UserInDb.fetchRequest()
        do {
            let data = try self.dbHelper.context.fetch(request)
            return data.count > 0
        }catch {
            print("Error: \(error.localizedDescription)")
            return false
        }
        
    }
    
    func searchDataInDb(searchTerm: String) -> [UserInDb]{
        let term = searchTerm.lowercased()
        let request = UserInDb.fetchRequest()
        let usernameContainPredicate = NSPredicate(format: "username CONTAINS[c] %@ OR username == %@ OR note CONTAINS[c] %@ OR note == %@",term,term,term,term)
        request.predicate = usernameContainPredicate
        do {
            let result = try self.dbHelper.context.fetch(request)
            print("Count result: \(result.count)")
            return result
        }catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func storeItem(userExistInDb: [UserInDb], singleUser: User,context:NSManagedObjectContext){
        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        let userInDb = self.dbHelper.add(UserInDb.self,context:context)
        userInDb?.id = Int64(singleUser.id)
        userInDb?.username = singleUser.username
        userInDb?.profileURL = singleUser.profileImageUrl
        userInDb?.detail = singleUser.profileDetail
    
        
    }
    
}

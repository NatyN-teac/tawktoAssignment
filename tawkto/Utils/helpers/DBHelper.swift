//
//  DBHelper.swift
//  tawkto
//
//  Created by mac on 06/02/2022.
//

import Foundation
import CoreData
import UIKit

class DBHelper {
    let container: NSPersistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
     let context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let bgContext  = container.newBackgroundContext()
        bgContext.automaticallyMergesChangesFromParent = true
        return bgContext
    }()
    
  
    
    func add<T: NSManagedObject>(_ type: T.Type, context: NSManagedObjectContext) -> T? {
        guard let entityName = T.entity().name else { return nil }
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return nil}
        let object = T(entity: entity, insertInto: context)
        return object
    }
    
    func update<T: NSManagedObject>(id: Int, type: T,userUpdate: User) {
        let fetchData = UserInDb.fetchRequest()
        fetchData.predicate = NSPredicate(format: "id==\(Int64(id))")
        
        do {
            let result = try context.fetch(fetchData)
            if !result.isEmpty {
                let user:UserInDb = result.first!
                user.detail = userUpdate.profileDetail
                user.username = userUpdate.username
                user.profileURL = userUpdate.profileImageUrl
            }
        }catch {
            print("in update \(error.localizedDescription)")

        }

    }
    
    func fetchSingle<T: NSManagedObject>(_ type: T.Type) -> T? {
        let fetchRequest = T.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let object = try context.fetch(fetchRequest).first
            return object as? T
        }catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func fetch<T: NSManagedObject>(_ type: T.Type,context: NSManagedObjectContext) -> [T] {
        let request = T.fetchRequest()
        
        do {
            let result = try context.fetch(request)
            return result as! [T]
        }catch {
            return []
        }
    }
    
    func save() {
        do {
            try context.save()
        }catch {
            print(error.localizedDescription)
        }
    }
}

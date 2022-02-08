//
//  AppDelegate.swift
//  tawkto
//
//  Created by mac on 04/02/2022.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      
        //mark: - To run on ios 12 not for 13+
//        let storyboard = UIStoryboard(name: K.StoryboardID.Main, bundle: .main)
//        let navController = storyboard.instantiateInitialViewController() as! UINavigationController
//        let usersListVC = navController.topViewController as! UserListViewController
//
//        let networkApi = NetworkApiService.shared
//        let networkMonitor = NetworkMonitorVM()
//        let dbHelper = DBHelper()
//        let dbServiceManager = DbService(helper: dbHelper)
//        let userListVM = UserListViewModel(serviceManager: networkApi,networkMonitor: networkMonitor,dbService: dbServiceManager)
//        usersListVC.userListViewModel = userListVM
//
//
//        window?.rootViewController = navController
//        window?.makeKeyAndVisible()

        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "tawkto")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support


}


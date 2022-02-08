//
//  SceneDelegate.swift
//  tawkto
//
//  Created by mac on 04/02/2022.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    
        //MARK: -Dependency Injection during intialization of scene.
//        let viewController = UserListViewController()
        guard let scene = (scene as? UIWindowScene) else { return }
        
        let storyboard = UIStoryboard(name: K.StoryboardID.Main, bundle: .main)
        let navController = storyboard.instantiateInitialViewController() as! UINavigationController
        let usersListVC = navController.topViewController as! UserListViewController

        let networkApi = NetworkApiService.shared
        let networkMonitor = NetworkMonitorVM()
        let dbHelper = DBHelper()
        let dbServiceManager = DbService(helper: dbHelper)
        let userListVM = UserListViewModel(serviceManager: networkApi,networkMonitor: networkMonitor,dbService: dbServiceManager)
        usersListVC.userListViewModel = userListVM

        window = UIWindow(windowScene: scene)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
//        var navigation = scene.windows.first?.rootViewController as? UINavigationController
       
        
//        viewController.userListViewModel = userListVM
//        navigation = UINavigationController(rootViewController: viewController)
//        guard let VC = navigation?.topViewController as? UserListViewController  else {
//            fatalError("unable to load VC")
//        }
      
        
//        VC.userListViewModel = userListVM
        
        
       
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
//        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}


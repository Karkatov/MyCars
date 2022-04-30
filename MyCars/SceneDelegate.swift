//
//  SceneDelegate.swift
//  MyCars
//
//  Created by Duxxless on 20.04.2022.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
      
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        let navController = UINavigationController()
        let vc = MyCarsViewController()
        vc.context = getContext()
        navController.viewControllers = [vc]
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    private func getContext() -> NSManagedObjectContext {
        let context = appDelegate.persistentContainer.viewContext
        return context
    }

}


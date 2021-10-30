//
//  AppDelegate.swift
//  OnsiteProject
//
//  Created by 陳翰霖 on 2021/10/26.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    //MARK: -  Core data Stack
        lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "StationDataModel")
            container.loadPersistentStores { description, error in
                if let error = error {
                    fatalError("Unable to load persistent stores: \(error)")
                }
            }
            return container
        }()
        func saveContext(){
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                }catch{
                    let err = error as NSError
                    print("DEBUG: Houston, we have problem with save core data!!")
                    fatalError("\(err), \(err.userInfo)")
                }
            }
        }
}


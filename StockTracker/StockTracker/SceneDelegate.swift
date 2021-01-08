//
//  SceneDelegate.swift
//  StockTracker
//
//  Created by Chenning Li on 11/16/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import UIKit
import SwiftUI
import Parse

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private(set) static var shared: SceneDelegate?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // Add event listener for when user logs out
        NotificationCenter.default.addObserver(forName: Notification.Name("login"), object: nil, queue: OperationQueue.main) { (Notification) in
            print("Logout notification received")
            // Load and show Login view controller
            self.login()
        }
        
        // Add event listener for when user logs out
        NotificationCenter.default.addObserver(forName: Notification.Name("didLogout"), object: nil, queue: OperationQueue.main) { (Notification) in
            print("Logout notification received")
            // Load and show Login view controller
            self.logOut()
        }
        
        Self.shared=self
        if let windowScene = scene as? UIWindowScene{
            let window = UIWindow(windowScene: windowScene)
            
            let style = UserDefaults.standard.integer(forKey: "LastStyle")
            window.overrideUserInterfaceStyle = (style == 0 ? .dark : UIUserInterfaceStyle(rawValue: style)!)

            let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController: UIViewController = mainStoryBoard.instantiateViewController(withIdentifier: "LoginViewController")

            window.rootViewController = viewController
            self.window = window
            window.makeKeyAndVisible()
        }
        
        if PFUser.current() != nil {
            login()
        }
        //        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func login() {
        // view controller currently being set in Storyboard as default will be overridden
        
        let connectionCheck = ConnectionCheck.isConnectedToNetwork()
        let mainViewController = MainViewController(from: getDefaultLists(),connectionCheck:connectionCheck)
        let mainView = MainView(mainViewController: mainViewController).environmentObject(mainViewController)
        let mainViewControllerNew = UIHostingController(rootView: mainView)
        
        self.window?.rootViewController = mainViewControllerNew
    }
    
    // ––––– Lab 5 TODO: LOGOUT USER
    func logOut() {
        PFUser.logOutInBackground(block: { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Successful Logout")
                
                let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let LoginViewController: UIViewController = mainStoryBoard.instantiateViewController(withIdentifier: "LoginViewController")

                self.window?.rootViewController = LoginViewController
                
            }
            
        })
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
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
    }
    
    
}


//
//  AppDelegate.swift
//  EmojiArtPersistantDataP2UIDocument
//
//  Created by Boppo Technologies on 04/06/19.
//  Copyright © 2019 Boppo Technologies. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    /*
     This is sent to your applicaation through other application like I wanna open up one of your documents
     This is only gonna get called if we have EmojiArt Document not a JSON document
 */
    
    func application(_ app: UIApplication, open inputURL: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Ensure the URL is a file URL
        guard inputURL.isFileURL else { return false }
                
        // Reveal / import the document at the URL
        guard let documentBrowserViewController = window?.rootViewController as? DocumentBrowserViewController else { return false }

        documentBrowserViewController.revealDocument(at: inputURL, importIfNeeded: true) { (revealedDocumentURL, error) in
            if let error = error {
                // Handle the error appropriately
                print("Failed to reveal the document at URL \(inputURL) with error: '\(error)'")
                return
            }
            
            // Present the Document View Controller for the revealed URL
            documentBrowserViewController.presentDocument(at: revealedDocumentURL!)
        }

        return true
    }


}

/*
 Making Files app kind of UI and to do that and make that easy make it simplify our existing code we need to use UIDocument
 
 UIDocument encapsulates aa document in this really beautiful way we have raelly nice API
 We could just do that here all
 I have to do is create UIDocument subclass and Implement 2 methods
 But this is where we are gonna step in and use that template
 And throw that template for document base
 
 
 DocumentBrowserViewController that looks like the files app in iOS 11
 and we arrive into the app there

 and then there is
 EmojiArtViewController we gonna delete default ViewController
 
 Cool thing about storyboard is you can copy and paste from 1 storyboard to another
 Because all the connection to the code are made by name
 So only the names
 So as long as the names are the same then both place it works
 
 
 There's no segue over here So that's why we have to do manual presenting over here
 */

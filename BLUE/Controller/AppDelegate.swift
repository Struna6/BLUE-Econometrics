//
//  AppDelegate.swift
//  BLUE
//
//  Created by Karol Struniawski on 12/11/2018.
//  Copyright © 2018 Karol Struniawski. All rights reserved.
//

import UIKit
import CoreData
import Tutti
import Firebase
import Purchases

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var adProvider = AdsProvider()
    var offer : Purchases.Package?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        loadApperanceOfTutorial()
        
        Purchases.debugLogsEnabled = true
        Purchases.configure(withAPIKey: "MEIbqeBzkzoXFMfBTrQDzgGGQdtylaiy")
        
        Purchases.shared.offerings { (offers, error) in
            if offers != nil{
                self.offer = offers?.current?.availablePackages.first
            }
        }
        
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if (purchaserInfo?.nonConsumablePurchases.count ?? -1) > 0 {
                self.adProvider.adsShouldBeVisible = false
            }
        }
        
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        GADMobileAds.disableAutomatedInAppPurchaseReporting()
        GADMobileAds.disableSDKCrashReporting()
        
        return true
    }
    
    func loadApperanceOfTutorial(){
        var pref = CalloutView.globalPreferences
        pref.drawing.backgroundColor = UIColor(red:0.24, green:0.33, blue:0.54, alpha:1.00)
        CalloutView.globalPreferences = pref
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
        // Saves changes in the application's managed object context before the application terminates.
    }
}


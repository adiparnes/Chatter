//
//  AppDelegate.swift
//  Chatter
//
//  Created by Avihai Shabtai on 22/02/2020.
//  Copyright © 2020 Niv-Ackerman. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

@available(iOS 13.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , CLLocationManagerDelegate {
 
    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?

    
    var locationManager: CLLocationManager?
    var coordinates: CLLocationCoordinate2D?

     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print(paths[0])
        
        
           FirebaseApp.configure()


        func userDidLogin(userId: String) {
//                  self.push.registerUserNotificationSettings()
//                  self.initSinchWithUserId(userId: userId)
//                 
              }
              
              NotificationCenter.default.addObserver(forName: NSNotification.Name(USER_DID_LOGIN_NOTIFICATION), object: nil, queue: nil) { (note) in
                  
                  let userId = note.userInfo![kUSERID] as! String
                  UserDefaults.standard.set(userId, forKey: kUSERID)
                  UserDefaults.standard.synchronize()
                  
                  userDidLogin(userId: userId)
              }
        
        return true
    }
    
       func applicationDidBecomeActive(_ application: UIApplication) {
            
            if FUser.currentUser() != nil {
                updateCurrentUserInFirestore(withValues: [kISONLINE : true]) { (success) in

                }
            }
            
            locationManagerStart()
        }
        
        
        func applicationDidEnterBackground(_ application: UIApplication) {
            
            recentBadgeHandler?.remove()
            if FUser.currentUser() != nil {
                updateCurrentUserInFirestore(withValues: [kISONLINE : false]) { (success) in
    
                }
            }

            locationMangerStop()
        }

    
    
    
//    // MARK: UISceneSession Lifecycle
//
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }

    
 
    
    
    
    //MARK:GoToApp
    
  

func goToApp() {

    NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
    
    let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplictaion") as! UITabBarController
    
    self.window?.rootViewController = mainView
}

    
    //MARK: Location manger
    
    func locationManagerStart() {
        
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
        }
        
        locationManager!.startUpdatingLocation()
    }

    func locationMangerStop() {
        
        if locationManager != nil {
            locationManager!.stopUpdatingLocation()
        }
    }
    
    //MARK: Location Manager delegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("faild to get location")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted:
            print("restricted")
        case .denied:
            locationManager = nil
            print("denied location access")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        coordinates = locations.last!.coordinate
    }
    
    

}

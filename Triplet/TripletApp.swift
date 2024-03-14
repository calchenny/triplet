//
//  TripletApp.swift
//  Triplet
//
//  Created by Derek Ma on 2/15/24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
}

@main
struct TripletApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        UISegmentedControl.appearance()
            .backgroundColor = UIColor(Color.evenLighterBlue)
        UISegmentedControl.appearance()
            .selectedSegmentTintColor = UIColor(Color.darkBlue)
        UISegmentedControl.appearance()
            .setTitleTextAttributes([.foregroundColor: UIColor(Color.darkBlue), .font: UIFont(name: "Poppins-Regular", size: 14) as Any], for: .normal)
        UISegmentedControl.appearance()
            .setTitleTextAttributes([.foregroundColor: UIColor(Color.evenLighterBlue)], for: .selected)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(LoginViewModel())
                .environmentObject(UserModel())
//            ItineraryView()
        }
    }
}

//
//  ThouchGameApp.swift
//  ThouchGame
//
//  Created by Frode Halrynjo on 16/02/2026.
//

import SwiftUI

// 1. Lag en AppDelegate for å styre orienteringen dynamisk
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.all // Standard er at alt er tillatt

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

@main
struct TouchGameApp: App {
    // 2. Koble AppDelegate til SwiftUI-appen
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

//
//  AppDelegate.swift
//  UniversalAppSwift
//
//  Created by huanyu.li on 2020/7/22.
//  Copyright © 2020 huanyu.li. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()

        window?.rootViewController = ViewController()
        LogDispatcher.sharedInstance.configLogger()

        AppVender.configVender()

        return true
    }

}

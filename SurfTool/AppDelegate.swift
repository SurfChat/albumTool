//
//  AppDelegate.swift
//  SurfTool
//
//  Created by Phenou on 22/11/2023.
//

import UIKit
import ActivityKit
import IQKeyboardManagerSwift
import Adjust

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 每次启动 需要记录一下时间 用于下次启动 更新照片的清晰度
        let lanuchTime = Date().timeIntervalSince1970
        UserDefaults.standard.setValue(lanuchTime, forKey: "sadAlbumLanuchTime")
        UserDefaults.standard.synchronize()
        
        PhotoBlurHandler.updateBlur()
        PhotoPurchHandler.share.purchesComplete()
        PhotoDBHandler.share.createExampleAlbum()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        
        let tabbar = PhotoTabbarController()
        window?.rootViewController = tabbar
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.reloadLayoutIfNeeded()
        
        startAnalyticePods()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if #available(iOS 16.2, *) {
            
            guard ActivityAuthorizationInfo().areActivitiesEnabled else {
                return
            }
       
            let att = islandAttributes()
            let content = islandAttributes.ContentState(star: PhotoBlurHandler.share.percent)
            let attContent = ActivityContent(state: content, staleDate: nil)
            do {
                let activity = try Activity<islandAttributes>.request(attributes: att, content: attContent)
                print("Requested a pizza delivery Live Activity \(activity.id)")
            } catch (let error) {
                print("Error requesting pizza delivery Live Activity \(error.localizedDescription)")
            }
           
            
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        if #available(iOS 16.1, *) {
            for activity in Activity<islandAttributes>.activities {
                Task {
                    await activity.end(using: nil, dismissalPolicy: .immediate)
                }
            }
        }
    }

    private func startAnalyticePods() {
        Bugly.start(withAppId: "adf6047a9b")
#if DEBUG
        let envi = ADJEnvironmentSandbox
#else
        let envi = ADJEnvironmentProduction
#endif
        let config = ADJConfig(appToken: "pj350203cqv4", environment: envi)
        Adjust.appDidLaunch(config)
    }
}


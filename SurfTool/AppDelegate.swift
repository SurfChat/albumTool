//
//  AppDelegate.swift
//  SurfTool
//
//  Created by Phenou on 22/11/2023.
//

import UIKit

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
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        
        let isVip = UserDefaults.standard.bool(forKey: "sadAlbumVip")
        let albums = PhotoDBHandler.share.queryAlbums()
        // 付费后且添加过照片 跳转相册列表
        if isVip && !albums.isEmpty {
            let listVc = AlbumListViewController()
            window?.rootViewController = UINavigationController(rootViewController: listVc)
        } else {
            let listVc = PhotoListViewController()
            listVc.isRoot = true
            window?.rootViewController = listVc
        }
        
        return true
    }

   


}


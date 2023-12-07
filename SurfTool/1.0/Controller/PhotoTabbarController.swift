//
//  PhotoTabbarController.swift
//  SurfTool
//
//  Created by Phenou on 6/12/2023.
//

import UIKit

class PhotoTabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        // Do any additional setup after loading the view.
        let happy = AlbumListViewController()
        happy.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tabbar_nomal")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "tabbar_happy")?.withRenderingMode(.alwaysOriginal))
        happy.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        addChild(UINavigationController(rootViewController: happy))
        
        let sad = AlbumListViewController()
        sad.scheme = 1
        sad.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tabbar_nomal")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "tabbar_sad")?.withRenderingMode(.alwaysOriginal))
        sad.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        addChild(UINavigationController(rootViewController: sad))
        
        let video = VideoListViewController()
        video.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tabbar_video")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "tabbar_video_sel")?.withRenderingMode(.alwaysOriginal))
        video.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        addChild(UINavigationController(rootViewController: video))
        
        let my = MyViewController()
        my.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tabbar_my")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "tabbar_my_sel")?.withRenderingMode(.alwaysOriginal))
        my.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        addChild(UINavigationController(rootViewController: my))
        
    }
    
}

extension PhotoTabbarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch selectedIndex {
        case 0:
            tabBar.backgroundColor = .clear
        case 1:
            tabBar.backgroundColor = .clear
        default:
            tabBar.backgroundColor = .white
        }
    }
}

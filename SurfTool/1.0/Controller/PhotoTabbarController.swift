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
        
        self.setValue(PhotoTabbar(), forKey:"tabBar")
        self.tabBar.tintColor = UIColor(red: 34 / 255, green: 34 / 255, blue: 34 / 255, alpha: 1.0)
        
//        self.delegate = self
        
        // Do any additional setup after loading the view.
        let happy = AlbumListViewController()
        happy.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tabbar_nomal")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "tabbar_happy")?.withRenderingMode(.alwaysOriginal))
        happy.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        addChild(PhotoNavViewController(rootViewController: happy))
        
        let sad = AlbumListViewController()
        sad.scheme = 1
        sad.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tabbar_nomal")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "tabbar_sad")?.withRenderingMode(.alwaysOriginal))
        sad.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        addChild(PhotoNavViewController(rootViewController: sad))
        
        let video = VideoListViewController()
        video.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tabbar_video")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "tabbar_video_sel")?.withRenderingMode(.alwaysOriginal))
        video.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        addChild(PhotoNavViewController(rootViewController: video))
        
        let my = MyViewController()
        my.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tabbar_my")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "tabbar_my_sel")?.withRenderingMode(.alwaysOriginal))
        my.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        addChild(PhotoNavViewController(rootViewController: my))
        
    }
    
    override func viewDidLayoutSubviews() {
        var frame = self.tabBar.frame
        frame.size.height = 90
        frame.origin.y = self.view.frame.size.height - frame.size.height - CGFloat(homeBarHeight > 0 ? 34 : 15)
        self.tabBar.frame = frame
    }
    
}

//extension PhotoTabbarController: UITabBarControllerDelegate {
//    
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        switch selectedIndex {
//        case 0:
//            tabBar.backgroundColor = .clear
//        case 1:
//            tabBar.backgroundColor = .clear
//        default:
//            tabBar.backgroundColor = .white
//        }
//    }
//}


class PhotoTabbar: UITabBar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initView(){
        //添加中间按钮
//        let width = 54
//        let middleButton = UIImageView(frame: CGRect(x: (Int(ScreenWidth) - width) / 2, y: 0, width: width, height: width))
//        middleButton.image = UIImage(named: "add")
//        middleButton.isUserInteractionEnabled = true
//        self .insertSubview(middleButton, at: 0)
       
        let bgView = UIView(frame: CGRect(x: 35, y: 36, width: UIScreen.main.bounds.width - 70, height: 44))
        bgView.backgroundColor = UIColor.hexColor(0xffffff, alphaValue: 0.8)
        bgView.layer.cornerRadius = 20
        bgView.layer.shadowColor = UIColor.hexColor(0x000000, alphaValue: 0.2).cgColor
        bgView.layer.shadowOffset = CGSize(width: 1, height: 1)
        bgView.layer.shadowOpacity = 0.8
        self.insertSubview(bgView, at: 1)

        //去掉顶部横线
        self.backgroundImage = UIImage()
        self.shadowImage = UIImage()
    }
    
    override func layoutSubviews() {
           super.layoutSubviews()
           let tabBarButtonW:CGFloat = (UIScreen.main.bounds.width - 70) / 4
           var tabBarButtonIndex:CGFloat = 0
           for child in self.subviews {
               let childClass: AnyClass? = NSClassFromString("UITabBarButton")
               if child.isKind(of: childClass!) {
                   let frame = CGRect(x: tabBarButtonIndex * tabBarButtonW + 35, y: 36, width: tabBarButtonW-10, height: 44)
                   child.frame = frame
//                   if tabBarButtonIndex == 2 {
//                       child.frame = CGRect(x: tabBarButtonIndex * tabBarButtonW + 15, y: 0, width: tabBarButtonW, height: 70)
//                   }
                   tabBarButtonIndex = tabBarButtonIndex + 1
               }
           }
       }
}

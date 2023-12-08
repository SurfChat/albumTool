//
//  AboutViewController.swift
//  SurfTool
//
//  Created by Phenou on 7/12/2023.
//

import UIKit

class AboutViewController: UIViewController {

    private lazy var navView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLab.text = "About us"
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalTo(backBtn.snp.trailing).offset(0)
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(view.snp.width).multipliedBy(0.35)
        }
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        view.addSubview(navView)
        navView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(navHeight)
        }
        
        let logo = UIImageView(image: UIImage(named: "AppIcon"))
        logo.layer.cornerRadius = 20
        logo.clipsToBounds = true
        view.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.top.equalTo(navHeight+50)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(100)
        }
        
        let verLab = UILabel()
        verLab.text = "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)"
        verLab.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        verLab.textColor = UIColor.hexColor(0x191919)
        view.addSubview(verLab)
        verLab.snp.makeConstraints { make in
            make.top.equalTo(logo.snp.bottom).offset(15)
            make.centerX.equalTo(logo)
        }
        
        let terms = UIButton(type: .custom)
        terms.backgroundColor = .white
        terms.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        terms.setTitle(" Terms of Use", for: .normal)
        terms.setTitleColor(UIColor.hexColor(0x191919), for: .normal)
        terms.setImage(UIImage(named: "web"), for: .normal)
        terms.addTarget(self, action: #selector(termsBtnClick), for: .touchUpInside)
        view.addSubview(terms)
        terms.snp.makeConstraints { make in
            make.top.equalTo(verLab.snp.bottom).offset(40)
            make.centerX.equalTo(verLab)
            make.height.equalTo(30)
        }
        
        let privacy = UIButton(type: .custom)
        privacy.backgroundColor = .white
        privacy.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        privacy.setTitle(" Privacy Policy", for: .normal)
        privacy.setTitleColor(UIColor.hexColor(0x191919), for: .normal)
        privacy.setImage(UIImage(named: "web"), for: .normal)
        privacy.addTarget(self, action: #selector(privacyBtnClick), for: .touchUpInside)
        view.addSubview(privacy)
        privacy.snp.makeConstraints { make in
            make.top.equalTo(terms.snp.bottom).offset(10)
            make.centerX.equalTo(terms)
            make.height.equalTo(30)
        }
        
        let contect = UIButton(type: .custom)
        contect.backgroundColor = .white
        contect.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        contect.setTitle(" Content Us", for: .normal)
        contect.setTitleColor(UIColor.hexColor(0x191919), for: .normal)
        contect.setImage(UIImage(named: "web"), for: .normal)
        contect.addTarget(self, action: #selector(contectBtnClick), for: .touchUpInside)
        view.addSubview(contect)
        contect.snp.makeConstraints { make in
            make.top.equalTo(privacy.snp.bottom).offset(10)
            make.centerX.equalTo(privacy)
            make.height.equalTo(30)
        }
    }
}

extension AboutViewController {
    @objc private func backBtnClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func termsBtnClick() {
        let webVc = PhotoWebViewController(url: "http://www.surf-chat.com/user-terms.html")
        webVc.title = "Terms of Use"
        navigationController?.pushViewController(webVc, animated: true)
    }
    
    @objc private func privacyBtnClick() {
        let webVc = PhotoWebViewController(url: "http://www.surf-chat.com/privacy-policy.html")
        webVc.title = "Privacy Policy"
        navigationController?.pushViewController(webVc, animated: true)
    }
    
    @objc private func contectBtnClick() {
        let webVc = PhotoWebViewController(url: "http://www.surf-chat.com/support.html")
        webVc.title = "Content Us"
        navigationController?.pushViewController(webVc, animated: true)
    }
}

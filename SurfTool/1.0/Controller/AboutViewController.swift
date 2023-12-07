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
    }
}

extension AboutViewController {
    @objc private func backBtnClick() {
        navigationController?.popViewController(animated: true)
    }
}

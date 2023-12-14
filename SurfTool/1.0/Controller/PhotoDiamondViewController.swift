//
//  PhotoDiamondViewController.swift
//  SurfTool
//
//  Created by Phenou on 28/11/2023.
//

import UIKit

class PhotoDiamondViewController: UIViewController {
    
    var isDiamond = false
    
    private lazy var navView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
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
        titleLab.text = "Purchase"
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalTo(backBtn.snp.trailing).offset(0)
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(view.snp.width).multipliedBy(0.35)
        }
        
        let restoreBtn = UIButton(type: .custom)
        restoreBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        restoreBtn.setTitleColor(UIColor.hexColor(0x333333, alphaValue: 1), for: .normal)
        restoreBtn.setTitle("Restore", for: .normal)
        restoreBtn.addTarget(self, action: #selector(restoreBtnClick), for: .touchUpInside)
        view.addSubview(restoreBtn)
        restoreBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.trailing.equalTo(-15)
            make.height.equalTo(44)
        }
        
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tab = UITableView(frame: .zero, style: .grouped)
        tab.register(PurchCell.self, forCellReuseIdentifier: "PurchCell")
        tab.rowHeight = 70
        tab.delegate = self
        tab.dataSource = self
        tab.separatorStyle = .none
        tab.backgroundColor = UIColor.hexColor(0xd7dfec, alphaValue: 1)
        tab.showsVerticalScrollIndicator = false
        return tab
    }()
    
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.hexColor(0xd7dfec, alphaValue: 1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(backBtnClick), name: NSNotification.Name("rechargeSucNoti"), object: nil)
        
        view.addSubview(navView)
        navView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(navHeight)
        }
        
        let buyBgView = UIView()
        buyBgView.backgroundColor = .white
        view.addSubview(buyBgView)
        buyBgView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(homeBarHeight+60)
        }
        
        let buyBtn = UIButton(type: .custom)
        buyBtn.backgroundColor = UIColor.hexColor(0xfd2d54, alphaValue: 1)
        buyBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        buyBtn.setTitle("Continue", for: .normal)
        buyBtn.setTitleColor(.white, for: .normal)
        buyBtn.layer.cornerRadius = 10
        buyBtn.addTarget(self, action: #selector(buyBtnClick), for: .touchUpInside)
        buyBgView.addSubview(buyBtn)
        buyBtn.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.leading.equalTo(50)
            make.height.equalTo(40)
            make.trailing.equalTo(-50)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(buyBgView.snp.top)
        }
        
        if isDiamond {
            if PhotoPurchHandler.share.diamondDatas.count > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                    let lastSectionIndex = self.tableView.numberOfSections - 1
                    let lastRowIndex = self.tableView.numberOfRows(inSection: lastSectionIndex) - 1
                    let lastIndexPath = IndexPath(row: lastRowIndex, section: lastSectionIndex)
                    self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
                }
            }
        }
        
    }
    
    @objc private func backBtnClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func buyBtnClick() {
        if let selectedIndexPath = selectedIndexPath {
            if selectedIndexPath.section == 0 {
                let data = PhotoPurchHandler.share.vipDatas[selectedIndexPath.row]
                
                PhotoPurchHandler.startBuyVip(model: data)
                
            } else {
                let data = PhotoPurchHandler.share.diamondDatas[selectedIndexPath.row]
                
                PhotoPurchHandler.startBuyCoin(model: data)
            }
        }
    }
}

extension PhotoDiamondViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return PhotoPurchHandler.share.vipDatas.count
        } else {
            return PhotoPurchHandler.share.diamondDatas.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PurchCell", for: indexPath) as! PurchCell
            cell.icon = "vip"
            if PhotoPurchHandler.share.vipDatas.count > indexPath.row {
                cell.data = PhotoPurchHandler.share.vipDatas[indexPath.row]
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PurchCell", for: indexPath) as! PurchCell
            cell.icon = "diamond"
            if PhotoPurchHandler.share.diamondDatas.count > indexPath.row {
                cell.data = PhotoPurchHandler.share.diamondDatas[indexPath.row]
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消之前选中的单元格的边框
        if let selectedIndexPath = selectedIndexPath {
            let cell = tableView.cellForRow(at: selectedIndexPath) as? PurchCell
            cell?.isSelected = false
        }
        
        // 设置选中单元格的边框
        let cell = tableView.cellForRow(at: indexPath) as? PurchCell
        cell?.isSelected = true
        
        selectedIndexPath = indexPath
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // 取消选中单元格的边框
        let cell = tableView.cellForRow(at: indexPath) as? PurchCell
        cell?.isSelected = false
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        let icon = UIImageView()
        view.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(40)
        }
        let titleLab = UILabel()
 
        titleLab.textColor = UIColor.hexColor(0x333333, alphaValue: 1)
        titleLab.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.top.equalTo(icon)
            make.leading.equalTo(icon.snp.trailing).offset(10)
        }
        
        let subtitleLab = UILabel()
        
        subtitleLab.textColor = UIColor.hexColor(0x666666, alphaValue: 1)
        subtitleLab.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        subtitleLab.numberOfLines = 2
        view.addSubview(subtitleLab)
        subtitleLab.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(0)
            make.leading.equalTo(icon.snp.trailing).offset(10)
            make.trailing.equalTo(-40)
        }
        
        if section == 0 {
            icon.image = UIImage(named: "album_add_big")
            titleLab.text = "Create more albums"
            subtitleLab.text = "Each album can only store up to 30 photos, you may need more albums."
        } else {
            icon.image = UIImage(named: "double_tap")
            titleLab.text = "Become clear"
            subtitleLab.text = "Pay 100 diamonds and double-click the photo to make it clearer."
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    @objc private func restoreBtnClick() {
        PhotoPurchHandler.restore()
    }
}

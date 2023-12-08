//
//  AlbumListViewController.swift
//  SurfTool
//
//  Created by Phenou on 27/11/2023.
//

import UIKit
import JFPopup
import SwiftUI

class AlbumListViewController: UIViewController {

    /// 主題0 happy 1 sad
    var scheme: Int = 0
    
    private lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: (homeBarHeight>0 ? homeBarHeight : 10), right: 15)
        layout.scrollDirection = .vertical
        let w = (UIScreen.main.bounds.width-40)/2.0
        layout.itemSize = CGSizeMake(w, w+35)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AlbumItemCell.self, forCellWithReuseIdentifier: "AlbumItemCell")
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
        
    }()
    
    private lazy var listView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = .white
        return bgView
    }()
    
    private lazy var navView: UIView = {
        let view = UIView()
        view.backgroundColor = .white

        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLab.textColor = UIColor.hexColor(0x333333, alphaValue: 1)
        titleLab.text = "Memories Album"
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalTo(15)
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        return view
    }()
    
    private lazy var editBtn: UIButton = {
        let editBtn = UIButton(type: .custom)
        editBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        editBtn.setTitleColor(UIColor.hexColor(0x333333, alphaValue: 1), for: .normal)
        editBtn.setImage(UIImage(named: "delete"), for: .normal)
        editBtn.setTitle("Delete", for: .normal)
        editBtn.addTarget(self, action: #selector(editBtnClick), for: .touchUpInside)
        return editBtn
    }()
    
    private lazy var cancelBtn: UIButton = {
        let editBtn = UIButton(type: .custom)
        editBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        editBtn.setTitleColor(UIColor.hexColor(0x333333, alphaValue: 1), for: .normal)
        editBtn.setImage(UIImage(named: "delete_del"), for: .normal)
        editBtn.setTitle("Cancel", for: .normal)
        editBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        editBtn.isHidden = true
        return editBtn
    }()
    
    private lazy var addAlbumBtn: UIButton = {
        let editBtn = UIButton(type: .custom)
        editBtn.setImage(UIImage(named: "album_add"), for: .normal)
        editBtn.addTarget(self, action: #selector(addAlbumBtnClick), for: .touchUpInside)
        editBtn.backgroundColor = .white
        editBtn.layer.cornerRadius = 30
        editBtn.layer.shadowColor = UIColor.hexColor(0x000000, alphaValue: 0.6).cgColor
        editBtn.layer.shadowOffset = CGSize(width: 1, height: 1)
        editBtn.layer.shadowOpacity = 0.8
        editBtn.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: 60, height: 60), cornerRadius: 30).cgPath

        return editBtn
    }()
    
    private lazy var meunView: UIHostingController = {
        var view = CircleMeunView()
        view.addAlbumAction = { [weak self] in
            self?.addAlbumBtnClick()
        }
        view.editListAction = { [weak self] in
            self?.editBtnClick()
        }
        view.endEditAction =  { [weak self] in
            self?.cancelBtnClick()
        }
        let vc = UIHostingController(rootView: view)
        vc.view.backgroundColor = .clear
        return vc
    }()
    
    private lazy var dataArr: [AlbumDBModel] = []
    private lazy var deleteDataArr: [AlbumDBModel] = []
    private lazy var isListEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        
        view.addSubview(navView)
        navView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(navHeight)
        }
                
        view.addSubview(listView)
        listView.snp.makeConstraints { make in
            make.top.equalTo(navView.snp.bottom)
            make.leading.equalTo(0)
            make.bottom.trailing.equalToSuperview()
        }
        
        
        let bottomBgImage = UIImageView(image: UIImage(named: "launch_bg"))
        if scheme == 1 {
            bottomBgImage.image = UIImage(named: "sad_bg")
        }
        listView.addSubview(bottomBgImage)
        bottomBgImage.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(bottomBgImage.snp.width).multipliedBy(375.0/308.0)
        }
        
        listView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(meunView.view)
        meunView.view.snp.makeConstraints { make in
            make.bottom.equalTo(-homeBarHeight-60)
            make.trailing.equalTo(-15)
            make.width.height.equalTo(200)
        }
        
        PhotoDBHandler.share.dbAlbumDataUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.setupData()
            }
        }
        
        setupData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupData() {
        if !dataArr.isEmpty {
            dataArr.removeAll()
            collectionView.reloadData()
        }
        
        let data = PhotoDBHandler.share.queryAlbums(scheme: scheme)

        if data.isEmpty && scheme == 0 {
            
            let alertController = UIAlertController(title: "Create Your First Happy Album", message: nil, preferredStyle: .alert)

            // 添加一个输入框
            alertController.addTextField { (textField) in
                textField.placeholder = "Album title"
            }

            let okAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] (_) in
                // 当用户点击确定按钮时执行的操作
                if let textField = alertController.textFields?.first {
                    if let text = textField.text {
                        let album = AlbumDBModel()
                        album.title = text
                        album.scheme = 0
                        PhotoDBHandler.share.addAlbum(album)
                        self?.perform(#selector(self?.goAddPhoto), with: nil, afterDelay: 0.5)
                    }
                }
            }

            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            dataArr.append(contentsOf: data)
            collectionView.reloadData()
        }
     }
    
}

extension AlbumListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumItemCell", for: indexPath) as! AlbumItemCell
        if dataArr.count > indexPath.item {
            cell.data = dataArr[indexPath.item]
        }
        cell.isEdit = isListEdit
        
        cell.markAction = { [weak self] data, isAdd in
            self?.selectDeletePhoto(data: data, isAdd: isAdd)
        }
        
        cell.updateTitle = { [weak self] albumID ,title in
            self?.updateAlbumTitle(ID: albumID, title: title)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if dataArr.count > indexPath.item  {
            let data = dataArr[indexPath.item]
            let listVc = PhotoListViewController()
            listVc.albumData = data
            navigationController?.pushViewController(listVc, animated: true)
        }
    }
}

extension AlbumListViewController {
    
    @objc private func editBtnClick() {
       
        if isListEdit == true {
            if deleteDataArr.count > 0 {
                deletePhoto()
            }
        } else {
            isListEdit = true
            collectionView.reloadData()
            cancelBtn.isHidden = false
        }
    }
    
    @objc private func cancelBtnClick() {

        cancelBtn.isHidden = true
        editBtn.isSelected = false
        isListEdit = false
        collectionView.reloadData()
        if deleteDataArr.count > 0 {
            deleteDataArr.removeAll()
        }
    }
    
    private func selectDeletePhoto(data: AlbumDBModel, isAdd: Bool) {
        if isAdd {
            deleteDataArr.append(data)
        } else {
            if let index = deleteDataArr.firstIndex(where: {$0.ID == data.ID}) {
                deleteDataArr.remove(at: index)
            }
        }
    }
    
    private func deletePhoto() {
        let alertController = UIAlertController(title: "Warm Tips", message: "Are you sure you want to delete the selected Albums?", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Sure", style: .default) { [weak self] (_) in
            // 当用户点击确定按钮时执行的操作
            guard let self = self else { return }
            PhotoDBHandler.share.deleteAlbum(self.deleteDataArr)
            self.cancelBtnClick()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in

        }

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        // 在视图控制器中显示警告框
        // 如果你在一个 UIViewController 中使用这段代码，请将 `self` 替换为你的视图控制器实例
        self.present(alertController, animated: true, completion: nil)

    }
    
    private func updateAlbumTitle(ID: Int64, title: String) {
        PhotoDBHandler.share.updateAlbumTitle(ID: ID, title: title)
    }
    
    @objc private func addAlbumBtnClick() {
        cancelBtnClick()
        let vip = UserDefaults.standard.double(forKey: "sadAlbumVipTill")
        
        if vip == 0 && dataArr.count > 0 {
            // 付费拦截
            let vip = PhotoDiamondViewController()
            navigationController?.pushViewController(vip, animated: true)
        } else {
            
            let sheet = UIAlertController(title: "Choose Album Type", message: nil, preferredStyle: .actionSheet)
            
            let option1Action = UIAlertAction(title: "Happy Album", style: .default) { [weak self] (action) in
                self?.createAlbum(albumType: 0)
            }
            sheet.addAction(option1Action)
            
            let option2Action = UIAlertAction(title: "Sad Album", style: .default) { [weak self] (action) in
                self?.createAlbum(albumType: 1)
            }
            sheet.addAction(option2Action)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            sheet.addAction(cancelAction)
            self.present(sheet, animated: true, completion: nil)
            
        }

    }
    
    private func createAlbum(albumType: Int) {
        var title = "Happy Album"
        if albumType == 1 {
            title = "Sad Album"
        }
        let alertController = UIAlertController(title: "Create New \(title)", message: nil, preferredStyle: .alert)
        
        // 添加一个输入框
        alertController.addTextField { (textField) in
            textField.placeholder = "Album title"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            // 当用户点击取消按钮时执行的操作
            
        }
        
        let okAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            // 当用户点击确定按钮时执行的操作
            if let textField = alertController.textFields?.first {
                if let text = textField.text {
                    let album = AlbumDBModel()
                    album.title = text
                    album.scheme = albumType
                    PhotoDBHandler.share.addAlbum(album)
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func goAddPhoto() {
         
        JFPopupView.popup.toast(hit: "Created successfully\nGo and add photos", icon: .success)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            if !self.dataArr.isEmpty {
                if let data = self.dataArr.first {
                    let listVc = PhotoListViewController()
                    listVc.albumData = data
                    self.navigationController?.pushViewController(listVc, animated: true)
                }
            }
        }

     }
    
}

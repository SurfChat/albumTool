//
//  AlbumListViewController.swift
//  SurfTool
//
//  Created by Phenou on 27/11/2023.
//

import UIKit
import IMProgressHUD

class AlbumListViewController: UIViewController {

    private lazy var listView: UICollectionView = {
        
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
        collectionView.backgroundColor = UIColor.hexColor(0xFFECF6, alphaValue: 1)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
        
    }()
    
    private lazy var navView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hexColor(0xFFECF6, alphaValue: 1)
    
        view.addSubview(userBtn)
        userBtn.snp.makeConstraints { make in
            make.leading.equalTo(5)
            make.bottom.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLab.textColor = UIColor.hexColor(0x333333, alphaValue: 1)
        titleLab.text = "Memories Album"
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalTo(userBtn.snp.trailing).offset(0)
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        return view
    }()
    
    private lazy var userBtn: UIButton = {
        let user = UIButton(type: .custom)
        user.setImage(UIImage(named: "user"), for: .normal)
        user.addTarget(self, action: #selector(userBtnClick), for: .touchUpInside)
        
        return user
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
    
    private lazy var userView: PhotoUserView = {
        let view = PhotoUserView()
        view.cellTapAction = { [weak self] type in
            self?.userListAction(type)
        }
        return view
    }()
    
    private lazy var dataArr: [AlbumDBModel] = []
    private lazy var deleteDataArr: [AlbumDBModel] = []
    private lazy var isListEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navView.addSubview(editBtn)
        editBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.trailing.equalTo(-15)
            make.height.equalTo(44)
        }
        
        navView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.bottom.height.equalTo(editBtn)
            make.trailing.equalTo(editBtn.snp.leading).offset(-10)
        }
        
        view.addSubview(navView)
        navView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(navHeight)
        }

        view.addSubview(userView)
        userView.snp.makeConstraints { make in
            make.top.equalTo(navView.snp.bottom)
            make.leading.equalTo(0)
            make.bottom.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.width*0.35)
        }
        
        view.addSubview(listView)
        listView.snp.makeConstraints { make in
            make.top.equalTo(navView.snp.bottom)
            make.leading.equalTo(0)
            make.bottom.trailing.equalToSuperview()
        }
        
        view.addSubview(addAlbumBtn)
        addAlbumBtn.snp.makeConstraints { make in
            make.bottom.equalTo(-homeBarHeight-50)
            make.trailing.equalTo(-15)
            make.height.width.equalTo(60)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if userBtn.isSelected {
            userBtn.sendActions(for: .touchUpInside)
        }
    }
    
    private func setupData() {
        if !dataArr.isEmpty {
            dataArr.removeAll()
        }
        
        let data = PhotoDBHandler.share.queryAlbums()

        if data.isEmpty {
            
            let alertController = UIAlertController(title: "Create your first album", message: nil, preferredStyle: .alert)

            // 添加一个输入框
            alertController.addTextField { (textField) in
                textField.placeholder = "Album title"
            }

            let okAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] (_) in
                // 当用户点击确定按钮时执行的操作
                if let textField = alertController.textFields?.first {
                    if let text = textField.text {
                        PhotoDBHandler.share.addAlbum(text)
                        self?.perform(#selector(self?.goAddPhoto), with: nil, afterDelay: 0.5)
                    }
                }
            }

            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            dataArr.append(contentsOf: data)
            listView.reloadData()
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
            listVc.albumID = data.ID
            listVc.albumTitle = data.title
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
            listView.reloadData()
            cancelBtn.isHidden = false
        }
    }
    
    @objc private func cancelBtnClick() {

        cancelBtn.isHidden = true
        editBtn.isSelected = false
        isListEdit = false
        listView.reloadData()
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
        
        let vip = UserDefaults.standard.double(forKey: "sadAlbumVipTill")

        if vip == 0 && dataArr.count > 0 {
            // 付费拦截
            userListAction(.vip)
        } else {
            
            let alertController = UIAlertController(title: "Create new album", message: nil, preferredStyle: .alert)

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
                        PhotoDBHandler.share.addAlbum(text)
                    }
                }
            }

            alertController.addAction(cancelAction)
            alertController.addAction(okAction)

            self.present(alertController, animated: true, completion: nil)
        }

    }
    
    @objc private func userBtnClick(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            userView.updateData()
            UIView.animate(withDuration: 0.3) {
                self.listView.snp.updateConstraints { make in
                    make.leading.equalTo(UIScreen.main.bounds.width*0.35)
                }
                self.view.layoutIfNeeded()
            }

        } else {
            UIView.animate(withDuration: 0.3) {
                self.listView.snp.updateConstraints { make in
                    make.leading.equalTo(0)
                }
                self.view.layoutIfNeeded()
            }
        }

    }
    
    @objc private func goAddPhoto() {
         
        IMProgressHUD.showToast("Created successfully, go and add photos")
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            if !self.dataArr.isEmpty {
                if let data = self.dataArr.first {
                    let listVc = PhotoListViewController()
                    listVc.albumID = data.ID
                    listVc.albumTitle = data.title
                    self.navigationController?.pushViewController(listVc, animated: true)
                }
            }
        }

     }
    
    private func userListAction(_ type: UserListType) {
        switch type {
        case .vip: do {
            let vip = PhotoDiamondViewController()
            navigationController?.pushViewController(vip, animated: true)
        }
            
        case .diamond: do {
            let diamond = PhotoDiamondViewController()
            diamond.isDiamond = true
            navigationController?.pushViewController(diamond, animated: true)
        }
            
        case .terms: do {
            let webVc = PhotoWebViewController(url: "http://www.surf-chat.com/user-terms.html")
            webVc.title = "Terms of Use"
            navigationController?.pushViewController(webVc, animated: true)
        }
            
        case .policy: do {
            let webVc = PhotoWebViewController(url: "http://www.surf-chat.com/privacy-policy.html")
            webVc.title = "Privacy Policy"
            navigationController?.pushViewController(webVc, animated: true)
        }
           
        default: break
        }
    }
}
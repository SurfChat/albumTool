//
//  AlbumListViewController.swift
//  SurfTool
//
//  Created by Phenou on 27/11/2023.
//

import UIKit

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
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
        
    }()
    
    private lazy var navView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLab.text = "Sad Album"
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalTo(15)
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

        view.addSubview(listView)
        listView.snp.makeConstraints { make in
            make.top.equalTo(navView.snp.bottom)
            make.leading.bottom.trailing.equalToSuperview()
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
    
    private func setupData() {
        if !dataArr.isEmpty {
            dataArr.removeAll()
        }
        
        let data = PhotoDBHandler.share.queryAlbums()

        dataArr.append(contentsOf: data)
        listView.reloadData()
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
            listVc.isRoot = false
            navigationController?.pushViewController(listVc, animated: true)
        }
    }
    

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
        
    }
}

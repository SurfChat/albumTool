//
//  PhotoListViewController.swift
//  SurfTool
//
//  Created by Phenou on 22/11/2023.
//

import UIKit
import SnapKit
import ZLPhotoBrowser

class PhotoListViewController: UIViewController {

    private let statusBarHeight: CGFloat = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        
    var navHeight: CGFloat {
        return statusBarHeight+44
    }
    
    let homeBarHeight: CGFloat = {
        if #available(iOS 11.0, *), let window = UIApplication.shared.windows.first {
            return window.safeAreaInsets.bottom
        } else {
            return 0
        }
    }()
    
    private lazy var listView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: (homeBarHeight>0 ? homeBarHeight : 10), right: 15)
        layout.scrollDirection = .vertical
        let w = (UIScreen.main.bounds.width-50)/3.0
        layout.itemSize = CGSizeMake(w, w)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: "PhotoItemCell")
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
    
    private lazy var confirmBtn: UIButton = {
        let editBtn = UIButton(type: .custom)
        
        return editBtn
    }()
    
    private lazy var dataArr: [PhotoDBModel] = []
    private lazy var deleteDataArr: [PhotoDBModel] = []
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
        PhotoDBHandler.share.dbDataUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.setupData()
            }
        }
        
        setupData()
    }
    
   private func setupData() {
       if !dataArr.isEmpty {
           dataArr.removeAll()
       }
       if let data = PhotoDBHandler.share.queryPhotos() {
           if data.count < 30 {
               let add = PhotoDBModel()
               add.ID = -1
               dataArr.append(add)
           }
           dataArr.append(contentsOf: data)
       } else {
           let add = PhotoDBModel()
           add.ID = -1
           dataArr.append(add)
       }
       
       listView.reloadData()
    }
    
}

extension PhotoListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoItemCell", for: indexPath) as! PhotoItemCell
        if dataArr.count > indexPath.item {
            cell.data = dataArr[indexPath.item]
        }
        cell.isEdit = isListEdit
        cell.addAction = { [weak self] in
            self?.presentPhotoPickerController()
        }
        cell.markAction = { [weak self] data, isAdd in
            self?.selectDeletePhoto(data: data, isAdd: isAdd)
        }
        return cell
    }
    
   private func presentPhotoPickerController() {
        ZLPhotoConfiguration.default()
            .maxSelectCount(10)
            .allowEditImage(false)
            .allowSelectGif(false)
            .allowSelectLivePhoto(false)
            .allowSelectVideo(false)
            .useCustomCamera(false)
        let ps = ZLPhotoPreviewSheet()
        
        ps.selectImageBlock = { results, isOriginal in
            PhotoDBHandler.share.addPhotos(results)
        }
        ps.showPhotoLibrary(sender: self)
    }
    
    @objc private func editBtnClick() {
       
        if isListEdit == true {
            if deleteDataArr.count > 0 {
                deletePhoto()
            }
        } else {
            isListEdit = true
            dataArr.remove(at: 0)
            listView.reloadData()
            cancelBtn.isHidden = false
        }
    }
    
    @objc private func cancelBtnClick() {

        cancelBtn.isHidden = true
        editBtn.isSelected = false
        isListEdit = false
        let add = PhotoDBModel()
        add.ID = -1
        dataArr.insert(add, at: 0)
        listView.reloadData()
        if deleteDataArr.count > 0 {
            deleteDataArr.removeAll()
        }
    }
    
    private func selectDeletePhoto(data: PhotoDBModel, isAdd: Bool) {
        if isAdd {
            deleteDataArr.append(data)
        } else {
            if let index = deleteDataArr.firstIndex(where: {$0.ID == data.ID}) {
                deleteDataArr.remove(at: index)
            }
        }
        print("\(deleteDataArr.count)")
    }
    
    private func deletePhoto() {
        let alertController = UIAlertController(title: "Warm Tips", message: "Are you sure you want to delete the selected photos?", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Sure", style: .default) { [weak self] (_) in
            // 当用户点击确定按钮时执行的操作
            guard let self = self else { return }
            PhotoDBHandler.share.deletePhotos(self.deleteDataArr)
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
}

extension UIColor {
    static func hexColor(_ hexValue: Int, alphaValue: Float) -> UIColor {
        return UIColor(red: CGFloat((hexValue & 0xFF0000) >> 16) / 255, green: CGFloat((hexValue & 0x00FF00) >> 8) / 255, blue: CGFloat(hexValue & 0x0000FF) / 255, alpha: CGFloat(alphaValue))
    }
}

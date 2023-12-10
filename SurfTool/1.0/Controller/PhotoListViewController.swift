//
//  PhotoListViewController.swift
//  SurfTool
//
//  Created by Phenou on 22/11/2023.
//

import UIKit
import SnapKit
import ZLPhotoBrowser
import JXPhotoBrowser

private let statusBarHeight: CGFloat = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

let navHeight: CGFloat = {
    return statusBarHeight+44
}()

let homeBarHeight: CGFloat = {
    if #available(iOS 11.0, *), let window = UIApplication.shared.windows.first {
        return window.safeAreaInsets.bottom
    } else {
        return 0
    }
}()

class PhotoListViewController: UIViewController {
    
    var albumData: AlbumDBModel?
    
    private lazy var listView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: (homeBarHeight>0 ? homeBarHeight : 10), right: 15)
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: "PhotoItemCell")
        collectionView.register(PhotoTextCell.self, forCellWithReuseIdentifier: "PhotoTextCell")
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
        
    }()
    
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
        titleLab.text = albumData?.title
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalTo(backBtn.snp.trailing).offset(0)
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(view.snp.width).multipliedBy(0.35)
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
        editBtn.isHidden = true
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
    
    private lazy var gruidView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width:UIScreen.main.bounds.width , height: UIScreen.main.bounds.height))
        
        view.backgroundColor = UIColor.hexColor(0x000000, alphaValue: 0.8)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(gruidViewTap))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
        let w = (UIScreen.main.bounds.width-50)/3.0
        let transparentRect = CGRect(x: w+15, y: navHeight, width: w+20, height: w+20)
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        
        let path = UIBezierPath(rect: view.bounds)
        let transparentRectPath = UIBezierPath(ovalIn: transparentRect)
        path.append(transparentRectPath)
        path.usesEvenOddFillRule = true
        
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        
        view.layer.mask = maskLayer
        
        let icon = UIImageView(image: UIImage(named: "double_tap_white"))
        view.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalTo(navHeight+30+w)
            make.leading.equalTo(w*1.5)
        }
        
        let lab = UILabel()
        lab.text = "Double Tap"
        lab.textColor = .white
        lab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lab.textAlignment = .center
        view.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.top.equalTo(icon.snp.bottom)
            make.centerX.equalTo(icon)
        }
        
        return view
    }()
    
    private lazy var dataArr: [PhotoDBModel] = []
    private lazy var deleteDataArr: [PhotoDBModel] = []
    private lazy var isListEdit = false
    private lazy var firstAdd = false
    private lazy var isAdd = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let bottomBgImage = UIImageView(image: UIImage(named: "launch_bg"))
        if albumData?.scheme == 1 {
            bottomBgImage.image = UIImage(named: "sad_bg")
        }
        view.addSubview(bottomBgImage)
        bottomBgImage.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(bottomBgImage.snp.width).multipliedBy(375.0/308.0)
        }
        
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
        
        firstAdd = !UserDefaults.standard.bool(forKey: "newUserAdd")
        
        setupData()
    }
    
    private func setupData() {
        if !dataArr.isEmpty {
            dataArr.removeAll()
        }
     
        var firstIndex = IndexPath(row: 1, section: 0)
        
        let data = PhotoDBHandler.share.queryPhotos(albumID: albumData?.ID ?? 0)
        if !data.isEmpty {
            PhotoDBHandler.share.updateAlbumCover(ID: albumData?.ID ?? 0, coverImage: data.first)
            if data.count < 30 {
                let add = PhotoDBModel()
                add.ID = -1
                dataArr.append(add)
            } else {
                firstIndex = IndexPath(row: 0, section: 0)
            }
            dataArr.append(contentsOf: data)
            editBtn.isHidden = false
            if firstAdd && albumData?.scheme == 1 {
                view.addSubview(gruidView)
            }
            
        } else {
            let add = PhotoDBModel()
            add.ID = -1
            dataArr.append(add)
            editBtn.isHidden = true
        }
        
        listView.reloadData()
        
        if isAdd && albumData?.scheme == 0 {
            isAdd = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.photoTap(index: firstIndex)
            }
        }
    }
    
    deinit {
        print("🗑️\(type(of: self)) deinitialized")
    }
}

extension PhotoListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if albumData?.scheme == 1 {
            
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
            cell.tapAction = { [weak self] in
                self?.photoTap(index: indexPath)
            }
            cell.doubleTapAction = { [weak self] in
                self?.photoDTap(index: indexPath)
            }
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoTextCell", for: indexPath) as! PhotoTextCell
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
            cell.tapAction = { [weak self] in
                self?.photoTap(index: indexPath)
            }
//            cell.doubleTapAction = { [weak self] in
//                self?.photoDTap(index: indexPath)
//            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if albumData?.scheme == 1 {
            let w = (UIScreen.main.bounds.width-50)/3.0
            return CGSizeMake(w, w)
         
        } else {
            let w = (UIScreen.main.bounds.width-40)/2.0
            return CGSizeMake(w, w+35)
        }
    }
    
    private func presentPhotoPickerController() {
        let editConfig = ZLEditImageConfiguration()
        editConfig.tools([.clip, ])
        editConfig.clipRatios([ZLImageClipRatio.wh1x1])
        
        ZLPhotoConfiguration.default()
            .maxSelectCount(1)
            .allowEditImage(true)
            .editImageConfiguration(editConfig)
            .allowSelectGif(false)
            .allowSelectLivePhoto(false)
            .allowSelectVideo(false)
            .cameraConfiguration(ZLCameraConfiguration().allowTakePhoto(false))
            .editAfterSelectThumbnailImage(true)
            .showClipDirectlyIfOnlyHasClipTool(true)
        
        let ps = ZLPhotoPreviewSheet()
        
        ps.selectImageBlock = { [weak self] results, isOriginal in
            self?.isAdd = true
            PhotoDBHandler.share.addPhotos(results, albumID: self?.albumData?.ID ?? 0, albumType: self?.albumData?.scheme ?? 0)
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
    
    @objc private func backBtnClick() {
        navigationController?.popViewController(animated: true)
    }
    
    private func selectDeletePhoto(data: PhotoDBModel, isAdd: Bool) {
        if isAdd {
            deleteDataArr.append(data)
        } else {
            if let index = deleteDataArr.firstIndex(where: {$0.ID == data.ID}) {
                deleteDataArr.remove(at: index)
            }
        }
    }
    
    private func deletePhoto() {
        let alertController = UIAlertController(title: "Warm Tips", message: "Are you sure you want to delete the selected photos?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Sure", style: .default) { [weak self] (_) in
            // 当用户点击确定按钮时执行的操作
            guard let self = self else { return }
            PhotoDBHandler.share.deletePhotos(self.deleteDataArr, albumID: self.albumData?.ID ?? 0)
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
    
    private func showBigImage(data: PhotoDBModel, hideText: Bool, updateAlbum: Bool) {
        if hideText {
            let browser = JXPhotoBrowser()
            browser.numberOfItems = {
                1
            }
            browser.cellClassAtIndex = { index in
                JXPhotoBrowserImageCell.self
            }
            browser.reloadCellAtIndex = { context in
                let browserCell = context.cell as? JXPhotoBrowserImageCell
                browserCell?.imageView.image = data.applyGaussianBlur() ?? UIImage()
            }
            browser.show()
        } else {
            let browser = PhotoFullViewController()
            browser.data = data
            browser.updateTitle = {[weak self] data in
                self?.updatePhotoDesc(data: data)
            }
            browser.updatePhoto =  {[weak self] data in
                self?.updatePhoto(data: data, updateAlbum: updateAlbum)
            }
            addChild(browser)
            view.addSubview(browser.view)
            browser.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            browser.show()
        }
    }
    
    @objc private func gruidViewTap() {
        let data = dataArr[1]
        data.percent = 0.05
        dataArr[1] = data
        PhotoDBHandler.share.updatePhoto(data, albumID: albumData?.ID ?? 0, updateAlbum: true)
        
        firstAdd = false
        UserDefaults.standard.setValue(true, forKey: "newUserAdd")
        UserDefaults.standard.synchronize()
        
        UIView.animate(withDuration: 0.3) {
            self.gruidView.alpha = 0
        } completion: { finish in
            self.gruidView.removeFromSuperview()
            self.listView.reloadItems(at: [IndexPath(item: 1, section: 0)])
        }
    }
    
    private func photoTap(index: IndexPath) {
        if dataArr.count > index.item {
            let data = dataArr[index.item]
            showBigImage(data: data, hideText: albumData?.scheme == 1, updateAlbum: index.item == 1)
        }
    }
    
    private func photoDTap(index: IndexPath) {
        let diamonds = UserDefaults.standard.integer(forKey: "sadAlbumDiamondsBalance")
        if diamonds > 0 {
            if dataArr.count > index.item {
                let data = dataArr[index.item]
                data.percent = data.percent*0.8
                dataArr[index.item] = data
                
                var updateAlbum = false
                if dataArr.count < 30 {
                    if index.item == 1 {
                        updateAlbum = true
                    }
                } else {
                    if index.item == 0 {
                        updateAlbum = true
                    }
                }
                
                PhotoDBHandler.share.updatePhoto(data, albumID: albumData?.ID ?? 0, updateAlbum: updateAlbum)
                
                UserDefaults.standard.setValue(diamonds-100, forKey: "sadAlbumDiamondsBalance")
                UserDefaults.standard.synchronize()
                
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                    self.listView.reloadItems(at: [index])
                }
            }
        } else {
            let diamond = PhotoDiamondViewController()
            diamond.isDiamond = true
            navigationController?.pushViewController(diamond, animated: true)
        }
    }
    
    private func updatePhotoDesc(data: PhotoDBModel) {
        PhotoDBHandler.share.updatePhotoText(data, albumID: data.albumID)
    }
    
    private func updatePhoto(data: PhotoDBModel, updateAlbum: Bool) {
        PhotoDBHandler.share.updatePhotoOriImage(data, albumID: data.albumID, updateAlbum: updateAlbum)
    }
}

extension UIColor {
    static func hexColor(_ hexValue: Int, alphaValue: Float = 1) -> UIColor {
        return UIColor(red: CGFloat((hexValue & 0xFF0000) >> 16) / 255, green: CGFloat((hexValue & 0x00FF00) >> 8) / 255, blue: CGFloat(hexValue & 0x0000FF) / 255, alpha: CGFloat(alphaValue))
    }
}

extension Date {
    func toString(format: String = "MM.dd.yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

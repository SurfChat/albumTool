//
//  VideoListViewController.swift
//  SurfTool
//
//  Created by Phenou on 6/12/2023.
//

import UIKit
import Photos
import ZLPhotoBrowser

class VideoListViewController: UIViewController {

    private lazy var navView: UIView = {
        let view = UIView()
        view.backgroundColor = .white

        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLab.textColor = UIColor.hexColor(0x333333, alphaValue: 1)
        titleLab.text = "Emotional video"
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalTo(15)
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        return view
    }()
    
    private lazy var listView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: (homeBarHeight>0 ? homeBarHeight : 10), right: 15)
        let w = (UIScreen.main.bounds.width-50)/3.0
        layout.itemSize = CGSize(width: w, height: w)
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(VideoListItem.self, forCellWithReuseIdentifier: "VideoListItem")
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.showsVerticalScrollIndicator = false
        
        return collectionView
        
    }()
    
    private var dataArr: [PHAsset] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(navView)
        navView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(navHeight)
        }
        
        view.addSubview(listView)
        listView.snp.makeConstraints { make in
            make.top.equalTo(navHeight)
            make.leading.bottom.trailing.equalToSuperview()
        }
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func loadData() {
        let smartAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        
        smartAlbum.enumerateObjects { collection, index, _ in
            if collection.localizedTitle == "Videos" {
                let videos = PHAsset.fetchAssets(in: collection, options: PHFetchOptions())
                videos.enumerateObjects { asset, index, _ in
                    if asset.mediaType == .video {
                        
                        self.dataArr.append(asset)
                    }
                }
            }
        }
        listView.reloadData()
    }
}

extension VideoListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoListItem", for: indexPath) as! VideoListItem
        if dataArr.count > indexPath.item {
            cell.videoData = dataArr[indexPath.item]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if dataArr.count > indexPath.item {
           let videoData = dataArr[indexPath.item]
            let videoEditVc = VideoEditViewController()
            videoEditVc.videoAsset = videoData
            navigationController?.pushViewController(videoEditVc, animated: true)
        }
    }
}

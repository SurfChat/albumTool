//
//  VideoEditViewController.swift
//  SurfTool
//
//  Created by Phenou on 8/12/2023.
//

import UIKit
import AVFoundation
import MediaWatermark
import Photos

class VideoEditViewController: UIViewController {
    var videoAsset: PHAsset! {
        didSet {
            let width = videoAsset.pixelWidth
            let height = videoAsset.pixelHeight
            videoScale = CGFloat(width) / CGFloat(height)
            
            let options = PHVideoRequestOptions()
            options.version = .current
            options.deliveryMode = .automatic
            options.isNetworkAccessAllowed = true
            
            let manager = PHImageManager.default()
            // PHAsset转AVURLAsset
            manager.requestAVAsset(forVideo: videoAsset, options: options) { [weak self] (asset, audioMix, info) in
                guard let urlAsset: AVURLAsset = asset as? AVURLAsset else {
                    return
                }
                self?.videoURLAsset = urlAsset
            }
        }
    }
    
    var videoURLAsset: AVURLAsset? {
        didSet {
            if let videoURLAsset = videoURLAsset {
                let item = AVPlayerItem(asset: videoURLAsset)
                let player = AVPlayer(playerItem: item)
                playerLayer.player = player
                if (playerLayer.player?.rate ?? 0) == 0 {
                    playerLayer.player?.play()
                }
            }
        }
    }
    
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
        
        let saveBtn = UIButton(type: .custom)
        saveBtn.setImage(UIImage(named: "save"), for: .normal)
        saveBtn.addTarget(self, action: #selector(saveBtnClick), for: .touchUpInside)
        view.addSubview(saveBtn)
        saveBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.trailing.equalTo(-15)
            make.height.equalTo(44)
        }
        
        return view
    }()
    
    private lazy var stickerView = {
        let view = PhotoStickerView()
        view.selectMarkImage = { [weak self] name in
            self?.showMarkImage(name: name)
        }
        return view
    }()
    
    private lazy var videoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.videoGravity = .resizeAspect
        return layer
    }()
    
    private lazy var markImageView: StickerView = {
        let imageView = StickerView(contentFrame:CGRect(x: 0, y: 0, width: 70, height: 70), contentImage: UIImage(named: "sticker_1"))
        imageView!.isHidden = true
        imageView!.backgroundColor = .clear
        return imageView!
    }()
    
    private var videoScale: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        // Do any additional setup after loading the view.
        view.addSubview(navView)
        navView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(navHeight)
        }
        
        view.addSubview(stickerView)
        stickerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(-homeBarHeight-20)
            make.height.equalTo(70)
        }
        
        let videoBgView = UIView()
        videoBgView.backgroundColor = .black
        view.addSubview(videoBgView)
        videoBgView.snp.makeConstraints { make in
            make.top.equalTo(navView.snp.bottom).offset(0)
            make.bottom.equalTo(stickerView.snp.top).offset(0)
            make.leading.trailing.equalToSuperview()
        }
        
        videoBgView.addSubview(videoView)
        videoView.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
            make.centerX.equalToSuperview()
            make.width.equalTo(videoView.snp.height).multipliedBy(videoScale)
        }
                
        view.layoutIfNeeded()
        playerLayer.frame = CGRect(x: 0, y: 0, width: videoView.bounds.size.width, height: videoView.bounds.size.height)
        videoView.layer.addSublayer(playerLayer)
        
        videoView.addSubview(markImageView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        playerLayer.player?.pause()
    }
    
    deinit {
        print("🗑️\(type(of: self)) deinitialized")
    }

}


extension VideoEditViewController {
    @objc private func backBtnClick() {
        navigationController?.popViewController(animated: true)
    }
    
    private func showMarkImage(name: String) {
        markImageView.isHidden = false
        markImageView.enabledBorder = true
        markImageView.enabledControl = true
        markImageView.contentImage = UIImage(named: name)
    }
    
    @objc private func saveBtnClick() {
        
        guard markImageView.isHidden == false else { return }
        
        guard let videoURLAsset = videoURLAsset else { return }
        
        
        markImageView.enabledBorder = false
        markImageView.enabledControl = false
        
//        WMCWaterMarkManager.addWaterMarkType(withVideoAsset: videoURLAsset, mark: [markImageView], markBgViews: [markImageView], cameraBgView: videoView) { url in
//            if let url = url {
//                print(url)
//            }
//        }
        
        let item = MediaItem(asset: videoURLAsset)

        let width = videoAsset.pixelWidth
        let scale = videoView.frame.size.width / CGFloat(width)
        let w = CGFloat(markImageView.frame.size.width*scale)
        
        
        
        let firstElement = MediaElement(view: markImageView)
        firstElement.frame = CGRect(x: markImageView.frame.origin.x*scale, y: markImageView.frame.origin.y*scale, width: w, height: w)
                            
        item.add(element: firstElement)
                
        let mediaProcessor = MediaProcessor()
      
        mediaProcessor.processElements(item: item) { [weak self] (result, error) in
            
            guard let self = self else { return }
            
//            if let resultImage = result. {
//                self.markImageView.isHidden = true
//                self.imageView.image = resultImage
//                if let newImageData = resultImage.jpegData(compressionQuality: 0) {
//                    self.data!.originalImage = newImageData
//                    self.updatePhoto?(self.data!)
//                }
//            }
        }
    }
}

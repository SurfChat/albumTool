//
//  VideoListItem.swift
//  SurfTool
//
//  Created by Phenou on 8/12/2023.
//

import UIKit
import Photos

class VideoListItem: UICollectionViewCell {
    var videoData: PHAsset? {
        didSet {
            if let videoData = videoData {
                let option = PHImageRequestOptions()
                let w = (UIScreen.main.bounds.width-50)/3.0
                PHImageManager.default().requestImage(for: videoData, targetSize: CGSize(width: w, height: w), contentMode: .default, options: option) { [weak self] image, info in
                    self?.imageView.image = image
                }
                
               
            }
        }
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var iconView = UIImageView(image: UIImage(named: "video_play"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .white
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
                
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.center.equalTo(imageView)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

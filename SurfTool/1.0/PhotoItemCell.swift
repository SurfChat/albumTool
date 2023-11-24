//
//  PhotoItemCell.swift
//  SurfTool
//
//  Created by Phenou on 23/11/2023.
//

import UIKit

class PhotoItemCell: UICollectionViewCell {
    
    var data: PhotoDBModel? {
        didSet {
            if let data = data {
                if data.originalImage.isEmpty {
                    addBtn.isHidden = false
                    iconView.isHidden = true
                    imageView.image = nil
                } else {
                    addBtn.isHidden = true
                    iconView.isHidden = false
                    imageView.image = data.applyGaussianBlur() ?? UIImage()
                }
            }
        }
    }
    
    var isEdit = false {
        didSet {
            markBtn.isHidden = !isEdit
            if isEdit == false {
                markBtn.isSelected = false
            }
        }
    }
    
    var addAction: (() -> Void)?
    
    var markAction: ((_ data: PhotoDBModel, _ isAdd: Bool) -> Void)?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var iconView = UIImageView(image: UIImage(named: "photo_pin"))
    
    private lazy var addBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "add_photo"), for: .normal)
        btn.addTarget(self, action: #selector(addBtnClick), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    private lazy var markBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "photo_nor"), for: .normal)
        btn.setImage(UIImage(named: "photo_sel"), for: .selected)
        btn.addTarget(self, action: #selector(markBtnClick), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor.hexColor(0xFFECF6, alphaValue: 1)
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
                
        contentView.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview()
            make.width.height.equalToSuperview().multipliedBy(0.5)
        }
        
        contentView.addSubview(addBtn)
        addBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(markBtn)
        markBtn.snp.makeConstraints { make in
            make.top.leading.equalTo(5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoItemCell {
    @objc private func addBtnClick() {
        addAction?()
    }
    
    @objc private func markBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        markAction?(data!, sender.isSelected)
    }
}

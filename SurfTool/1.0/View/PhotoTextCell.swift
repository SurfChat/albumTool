//
//  PhotoTextCell.swift
//  SurfTool
//
//  Created by Phenou on 4/12/2023.
//

import UIKit

class PhotoTextCell: UICollectionViewCell {
    
    var data: PhotoDBModel? {
        didSet {
            if let data = data {
                if data.originalImage.isEmpty {
                    addBtn.isHidden = false
                    imageView.image = nil
                    titleLab.text = ""
                } else {
                    addBtn.isHidden = true
                    imageView.image = UIImage(data: data.originalImage)
                    if !data.text.isEmpty {
                        titleLab.text = data.text
                    } else {
                        titleLab.text = ""
                    }
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
    
    var tapAction: (() -> Void)?
    var doubleTapAction: (() -> Void)?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
        
    private lazy var addBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "add_photo"), for: .normal)
        btn.addTarget(self, action: #selector(addBtnClick), for: .touchUpInside)
        btn.backgroundColor = UIColor.hexColor(0xFFECF6, alphaValue: 1)
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
    
    private lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lab.textColor = UIColor.hexColor(0x666666, alphaValue: 1)
        lab.numberOfLines = 2
        lab.minimumScaleFactor = 0.5
        lab.lineBreakMode = .byCharWrapping
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .white
        contentView.layer.shadowColor = UIColor.hexColor(0x000000, alphaValue: 0.6).cgColor
        contentView.layer.shadowOffset = CGSize(width: 1, height: 1)
        contentView.layer.shadowOpacity = 0.8
        let w = (UIScreen.main.bounds.width-40)/2.0
        contentView.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: w, height: w+35), cornerRadius: 0).cgPath

        let tap2 = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        tap2.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(tap2)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        tap.numberOfTapsRequired = 1
        tap.require(toFail: tap2)
        contentView.addGestureRecognizer(tap)
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(imageView.snp.width).multipliedBy(1)
        }
        
        contentView.addSubview(addBtn)
        addBtn.snp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }

        contentView.addSubview(markBtn)
        markBtn.snp.makeConstraints { make in
            make.top.leading.equalTo(5)
        }
        
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(5)
            make.leading.equalTo(15)
            make.bottom.equalTo(-5)
            make.trailing.equalTo(-15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoTextCell {
    @objc private func addBtnClick() {
        addAction?()
    }
    
    @objc private func markBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        markAction?(data!, sender.isSelected)
    }
    
    @objc private func doubleTap() {
        doubleTapAction?()
    }
    
    @objc private func tap() {
        tapAction?()
    }
}

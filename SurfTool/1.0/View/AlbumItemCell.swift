//
//  AlbumItemCell.swift
//  SurfTool
//
//  Created by Phenou on 27/11/2023.
//

import UIKit

class AlbumItemCell: UICollectionViewCell {
    var data: AlbumDBModel? {
        didSet {
            imageView.image = UIImage(data: data?.coverImage ?? Data()) ?? UIImage()
            titleLab.text = data?.title
            dateLab.text = data?.createTime
            if data?.scheme == 1 {
                contentView.backgroundColor = UIColor.hexColor(0xd7dfec, alphaValue: 1)
            } else {
                contentView.backgroundColor = UIColor.hexColor(0xFFECF6, alphaValue: 1)
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
    
    var markAction: ((_ data: AlbumDBModel, _ isAdd: Bool) -> Void)?
    var updateTitle:((_ ID: Int64, _ newTitle: String) -> Void)?
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var markBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "photo_nor"), for: .normal)
        btn.setImage(UIImage(named: "photo_sel"), for: .selected)
        btn.addTarget(self, action: #selector(markBtnClick), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    private lazy var titleLab: UITextField = {
        let lab = UITextField()
        lab.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        lab.delegate = self
        lab.returnKeyType = .done
        return lab
    }()
    
    private lazy var editBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "album_edit"), for: .normal)
        btn.addTarget(self, action: #selector(editBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var dateLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        lab.textColor = UIColor.hexColor(0x999999, alphaValue: 1)
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
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(15)
            make.height.equalTo(imageView.snp.width).multipliedBy(1)
        }
        
        contentView.addSubview(dateLab)
        dateLab.snp.makeConstraints { make in
            make.leading.equalTo(15)
            make.bottom.equalTo(-5)
            make.trailing.equalTo(-15)
            make.height.equalTo(10)
        }
        
        let bgView = UIView()
        bgView.backgroundColor = .clear
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(dateLab.snp.top)
        }
        
        contentView.addSubview(markBtn)
        markBtn.snp.makeConstraints { make in
            make.top.leading.equalTo(5)
        }
        
        bgView.addSubview(editBtn)
        editBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(-15)
            make.width.height.equalTo(15)
        }
        
        bgView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalTo(15)
            make.centerY.equalTo(editBtn)
            make.trailing.equalTo(editBtn.snp.leading).offset(-5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension AlbumItemCell: UITextFieldDelegate {
    @objc private func markBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        markAction?(data!, sender.isSelected)
    }
    
    @objc private func editBtnClick() {
        titleLab.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let title = textField.text, let data = data {
            updateTitle?(data.ID ,title)
        }
        return true
    }
}


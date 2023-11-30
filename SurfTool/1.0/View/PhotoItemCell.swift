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
                    showFlowLight = data.percent > 0.5
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
    
    private var showFlowLight = false {
        didSet {
            guideView.isHidden = !showFlowLight
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
    
    private lazy var guideView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor.hexColor(0xFFECF6, alphaValue: 1)

        let tap2 = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        tap2.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(tap2)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        tap.numberOfTapsRequired = 1
        tap.require(toFail: tap2)
        contentView.addGestureRecognizer(tap)
        
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
        
        contentView.addSubview(guideView)
        guideView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.addSubview(markBtn)
        markBtn.snp.makeConstraints { make in
            make.top.leading.equalTo(5)
        }
        
        layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            let gradint = CAGradientLayer()
            let middleRef = UIColor.white.withAlphaComponent(0.6).cgColor
            let fadeRef = UIColor.white.withAlphaComponent(0.0).cgColor
            gradint.colors = [fadeRef,middleRef,fadeRef]
            gradint.locations = [NSNumber(floatLiteral: 0.6), NSNumber(floatLiteral: 0.98), NSNumber(floatLiteral: 1.0)]
            gradint.startPoint = CGPoint(x: 0, y: 0)
            gradint.endPoint = CGPoint(x: 1, y: 0)
            let w = (UIScreen.main.bounds.width-50)/3.0
            let rect = CGRect(x: 0, y: 0, width: w, height: w)
            gradint.frame = rect
            
            self.guideView.layer.addSublayer(gradint)
            let startX = -rect.size.width
            let endX = 100
            
            let flowAni = CAKeyframeAnimation(keyPath: "transform.translation.x")
            let duration = 2.5
            let interval = 1.0
            let times = duration / (duration+interval)
            flowAni.values = [startX, endX, endX]
            flowAni.duration = duration + interval
            flowAni.keyTimes = [NSNumber(floatLiteral: 0), NSNumber(floatLiteral: times), NSNumber(floatLiteral: 1)]
            flowAni.repeatCount = 2
            flowAni.isRemovedOnCompletion = false
            flowAni.fillMode = CAMediaTimingFillMode.forwards
            gradint.add(flowAni, forKey: "guideView")
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
    
    @objc private func doubleTap() {
        doubleTapAction?()
    }
    
    @objc private func tap() {
        tapAction?()
    }
}

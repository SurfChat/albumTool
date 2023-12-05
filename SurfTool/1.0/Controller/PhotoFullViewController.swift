//
//  PhotoFullViewController.swift
//  SurfTool
//
//  Created by Phenou on 4/12/2023.
//

import UIKit
import RSKGrowingTextView
import MediaWatermark

class PhotoFullViewController: UIViewController {
    
    var updateTitle:((_ data: PhotoDBModel) -> Void)?
    var updatePhoto:((_ data: PhotoDBModel) -> Void)?
    
    var data: PhotoDBModel?
    
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
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(data: data?.originalImage ?? Data())
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var textView: RSKGrowingTextView = {
        let textView = RSKGrowingTextView()
        textView.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textView.textColor = UIColor.hexColor(0x666666, alphaValue: 1)
        textView.placeholder = "The Happy Memory"
        textView.placeholderColor = UIColor.hexColor(0x8B8A8F, alphaValue: 1)
        textView.maximumNumberOfLines = 2
        textView.backgroundColor = .white
        textView.returnKeyType = .done
        textView.delegate = self
        textView.text = data?.text ?? ""
        return textView
    }()
    
    private lazy var editBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .white
        btn.setImage(UIImage(named: "album_edit"), for: .normal)
        btn.addTarget(self, action: #selector(editBtnClick), for: .touchUpInside)
        return btn
    }()
    
    private lazy var stickerView = {
        let view = PhotoStickerView()
        view.selectMarkImage = { [weak self] name in
            self?.showMarkImage(name: name)
        }
        return view
    }()
    
    private lazy var markImageView: StickerView = {
        let imageView = StickerView(contentFrame:CGRect(x: 0, y: 0, width: 70, height: 70), contentImage: UIImage(named: "sticker_1"))
        imageView!.isHidden = true
        imageView!.backgroundColor = .clear
        return imageView!
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.alpha = 0
        view.backgroundColor = .white
        
        let bottomBgImage = UIImageView(image: UIImage(named: "launch_bg"))
        view.addSubview(bottomBgImage)
        bottomBgImage.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(bottomBgImage.snp.width).multipliedBy(375.0/308.0)
        }
        
        view.addSubview(navView)
        navView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(navHeight)
        }
                
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.layer.shadowColor = UIColor.hexColor(0x000000, alphaValue: 0.6).cgColor
        bgView.layer.shadowOffset = CGSize(width: 1, height: 1)
        bgView.layer.shadowOpacity = 0.8
        let w = UIScreen.main.bounds.width-60
        bgView.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: w, height: w*1.2), cornerRadius: 0).cgPath
        view.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalTo(30)
            make.trailing.equalTo(-30)
            make.height.equalTo(bgView.snp.width).multipliedBy(1.2)
        }

        bgView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.height.equalTo(imageView.snp.width).multipliedBy(1)
        }
        
        imageView.addSubview(markImageView)
        
        bgView.addSubview(editBtn)
        editBtn.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.bottom.equalToSuperview()
            make.trailing.equalTo(-10)
            make.width.equalTo(30)
        }
        
        bgView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.centerY.equalTo(editBtn)
            make.leading.equalTo(15)
            make.trailing.equalTo(editBtn.snp.leading).offset(-15)
        }
        
        view.addSubview(stickerView)
        stickerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(-homeBarHeight-20)
            make.height.equalTo(70)
        }
    }

    deinit {
        print("🗑️\(type(of: self)) deinitialized")
    }
    
    func show() {
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 1
        }
    }
}


extension PhotoFullViewController: UITextViewDelegate {
    
    @objc private func backBtnClick() {
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 0
        } completion: { finish in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }

    }
    
    @objc private func editBtnClick() {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        } else {
            textView.becomeFirstResponder()
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            // Return 键被点击
            print("Return key pressed")
            editBtnClick()
            return false // 返回 false 可以阻止换行符的插入
        }
        return true
    }
    
    private func showMarkImage(name: String) {
        markImageView.isHidden = false
        markImageView.enabledBorder = true
        markImageView.enabledControl = true
        markImageView.contentImage = UIImage(named: name)
    }
    
    @objc private func saveBtnClick() {
        if !textView.text.isEmpty {
            data?.text = textView.text
            updateTitle?(data!)
        }
        
        guard let imageData = data?.originalImage else { return }
        
        guard let image = UIImage(data: imageData) else { return }
        
        let item = MediaItem(image:image)
        
        markImageView.enabledBorder = false
        markImageView.enabledControl = false
        
        let scale = CGFloat(image.size.width/imageView.frame.size.width)
        let w = CGFloat(markImageView.frame.size.width*scale)
        
        let firstElement = MediaElement(view: markImageView)
        firstElement.frame = CGRect(x: markImageView.frame.origin.x*scale, y: markImageView.frame.origin.y*scale, width: w, height: w)
                            
        item.add(element: firstElement)
                
        let mediaProcessor = MediaProcessor()
        mediaProcessor.processElements(item: item) { [weak self] (result, error) in
            
            guard let self = self else { return }
            // handle result
            if let resultImage = result.image {
                self.markImageView.isHidden = true
                self.imageView.image = resultImage
                if let newImageData = resultImage.jpegData(compressionQuality: 0) {
                    self.data!.originalImage = newImageData
                    self.updatePhoto?(self.data!)
                }
            }
        }
    }

}

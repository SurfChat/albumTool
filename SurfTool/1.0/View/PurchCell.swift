//
//  PurchCell.swift
//  SurfTool
//
//  Created by Phenou on 29/11/2023.
//

import UIKit
import StoreKit

class PurchCell: UITableViewCell {
    
    var data: SKProduct? {
        didSet {
            if let data = data {
                let numFormatter = NumberFormatter()
                numFormatter.formatterBehavior = .behavior10_4
                numFormatter.numberStyle = .currency
                numFormatter.locale = data.priceLocale
                priceLab.text = numFormatter.string(from: data.price) ?? ""
                countLab.text = data.localizedTitle
            }
        }
    }
    
    var icon: String = "" {
        didSet {
            imgView.image = UIImage(named: icon)
        }
    }
    
    private lazy var bgView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 10
        bgView.clipsToBounds = true
        bgView.layer.borderColor = UIColor.hexColor(0xfd2d54, alphaValue: 1).cgColor
        return bgView
    }()
    
    private lazy var imgView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var countLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lab.textColor = UIColor.hexColor(0x333333, alphaValue: 1)
        return lab
    }()
    
    private lazy var priceLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lab.textColor = UIColor.hexColor(0x333333, alphaValue: 1)
        return lab
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor.hexColor(0xd7dfec, alphaValue: 1)
        
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.leading.equalTo(25)
            make.bottom.equalTo(-10)
            make.trailing.equalTo(-25)
        }
        
        bgView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(15)
        }
        
        bgView.addSubview(countLab)
        countLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(imgView.snp.trailing).offset(5)
        }
        
        bgView.addSubview(priceLab)
        priceLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(-15)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            bgView.layer.borderWidth = 2
        } else {
            bgView.layer.borderWidth = 0
        }
    }

}

//
//  PhotoInfoCell.swift
//  SurfTool
//
//  Created by Phenou on 7/12/2023.
//

import UIKit
import SwiftUI

class PhotoInfoCell: UITableViewCell {
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        contentView.clipsToBounds = true
        
        for view in contentView.subviews {
            view.removeFromSuperview()
        }
        
        let pieView = PieChartView(
            values: PhotoDBHandler.share.queryPhotosInfo(),
            colors: [Color(UIColor.hexColor(0xFFECF6, alphaValue: 1)),Color(UIColor.hexColor(0xd7dfec, alphaValue: 1))],
            backgroundColor: .white,
            configuration: PieChartView.Configuration(space: 0.5, hole: 0.6)
        )
        let meunView = UIHostingController(rootView: pieView)
        meunView.view.backgroundColor = .white
        
        contentView.addSubview(meunView.view)
        meunView.view.snp.makeConstraints { make in
            make.top.equalTo(-10)
            make.leading.equalTo(20)
            make.width.height.equalTo(200)
        }
        
        let bgView = UIView()
        bgView.backgroundColor = .white
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.centerX.equalTo(meunView.view)
            make.bottom.equalToSuperview()
            make.height.equalTo(30)
        }
        
        let happy = UIView()
        happy.backgroundColor = UIColor.hexColor(0xFFECF6, alphaValue: 1)
        bgView.addSubview(happy)
        happy.snp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
            make.width.height.equalTo(14)
        }
        
        let happyLab = UILabel()
        happyLab.text = "Happy photos"
        happyLab.textColor = UIColor.hexColor(0x333333, alphaValue: 1)
        happyLab.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        bgView.addSubview(happyLab)
        happyLab.snp.makeConstraints { make in
            make.centerY.equalTo(happy)
            make.leading.equalTo(happy.snp.trailing).offset(5)
        }
        
        
        let sad = UIView()
        sad.backgroundColor = UIColor.hexColor(0xd7dfec, alphaValue: 1)
        bgView.addSubview(sad)
        sad.snp.makeConstraints { make in
            make.centerY.equalTo(happy)
            make.leading.equalTo(happyLab.snp.trailing).offset(15)
            make.width.height.equalTo(14)
        }
        
        let sadLab = UILabel()
        sadLab.text = "Sad photos"
        sadLab.textColor = UIColor.hexColor(0x333333, alphaValue: 1)
        sadLab.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        bgView.addSubview(sadLab)
        sadLab.snp.makeConstraints { make in
            make.centerY.equalTo(happy)
            make.leading.equalTo(sad.snp.trailing).offset(5)
            make.trailing.equalToSuperview()
        }
        
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        lab.textColor = UIColor.hexColor(0x333333, alphaValue: 1)
        lab.text = "Congratulations, happiness surrounds you!"
        lab.numberOfLines = 0
        let arr: [Int] = PhotoDBHandler.share.queryPhotosInfo()
        if arr.first ?? 0 < arr.last ?? 0 {
            lab.text = "Come on, make your life better!"
        }
        
        contentView.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.centerY.equalTo(meunView.view)
            make.leading.equalTo(meunView.view.snp.trailing).offset(10)
            make.trailing.equalTo(-15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

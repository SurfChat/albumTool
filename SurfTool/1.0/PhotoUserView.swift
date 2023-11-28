//
//  PhotoUserView.swift
//  SurfTool
//
//  Created by Phenou on 28/11/2023.
//

import UIKit

enum UserListType {
    case none
    case vip
    case diamond
    case terms
    case policy
}

class PhotoUserView: UIView {
    var cellTapAction: ((_ cellType: UserListType) -> Void)?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.register(UserListCell.self, forCellReuseIdentifier: "UserListCell")
        return tableView
    }()
    
    private let viewModel = UserListViewModel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.hexColor(0xd7dfec, alphaValue: 0.8)
        
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PhotoUserView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell", for: indexPath) as! UserListCell
        if viewModel.dataArr.count > indexPath.row {
            cell.data = viewModel.dataArr[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.dataArr.count > indexPath.row {
            let data = viewModel.dataArr[indexPath.row]
            cellTapAction?(data.type)
        }
    }
}

class UserListCell: UITableViewCell {
    
    var data: UserListModel! {
        didSet {
            if data.icon.isEmpty {
                imgView.isHidden = true
            } else {
                imgView.isHidden = false
                imgView.image = UIImage(named: data.icon)
            }
            lab.text = data.title
        }
    }
    
    private lazy var imgView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    private lazy var lab: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor.hexColor(0x333333, alphaValue: 1)
        lab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return lab
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        let bgView = UIStackView(arrangedSubviews: [imgView, lab])
        bgView.axis = .horizontal
        bgView.spacing = 5
        bgView.alignment = .leading
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.leading.equalTo(15)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(-10)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class UserListViewModel {
    
    var dataArr: [UserListModel] = []
    
    init() {
        let vip = UserListModel()
        vip.title = "VIP"
        vip.icon = "vip"
        vip.type = .vip
        
        let coin = UserListModel()
        coin.title = "Diamond"
        coin.icon = "diamond"
        coin.type = .diamond
        
        let agreement = UserListModel()
        agreement.title = "Terms of Use"
        agreement.type = .terms
        
        let privacy = UserListModel()
        privacy.title = "Privacy Policy"
        privacy.type = .policy
        
        let ver = UserListModel()
        ver.title = "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)"
        
        
        dataArr.append(vip)
        dataArr.append(coin)
        dataArr.append(agreement)
        dataArr.append(privacy)
        dataArr.append(ver)
    }
}

class UserListModel {
    
    var title: String = ""
    var icon: String = ""
    var type: UserListType = .none
}

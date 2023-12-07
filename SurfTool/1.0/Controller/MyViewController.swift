//
//  MyViewController.swift
//  SurfTool
//
//  Created by Phenou on 6/12/2023.
//

import UIKit

enum UserListType {
    case none
    case vip
    case diamond
    case terms
    case policy
    case about
}

class MyViewController: UIViewController {

    private lazy var navView: UIView = {
        let view = UIView()
        view.backgroundColor = .white

        let titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLab.textColor = UIColor.hexColor(0x333333, alphaValue: 1)
        titleLab.text = "Memories Album"
        view.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.leading.equalTo(15)
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.register(UserListCell.self, forCellReuseIdentifier: "UserListCell")
        tableView.register(PhotoInfoCell.self, forCellReuseIdentifier: "PhotoInfoCell")
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let viewModel = UserListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(navView)
        navView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(navHeight)
        }
                
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(navHeight)
            make.leading.bottom.trailing.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: NSNotification.Name("rechargeSucNoti"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
    }
}


extension MyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.dataArr.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoInfoCell", for: indexPath) as! PhotoInfoCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell", for: indexPath) as! UserListCell
            if viewModel.dataArr.count > indexPath.row-1 {
                cell.data = viewModel.dataArr[indexPath.row-1]
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 120
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.dataArr.count > indexPath.row-1 {
            let data = viewModel.dataArr[indexPath.row-1]
            switch data.type {
            case .vip: do {
                let vip = PhotoDiamondViewController()
                navigationController?.pushViewController(vip, animated: true)
            }
                
            case .diamond: do {
                let diamond = PhotoDiamondViewController()
                diamond.isDiamond = true
                navigationController?.pushViewController(diamond, animated: true)
            }
                
            case .terms: do {
                let webVc = PhotoWebViewController(url: "http://www.surf-chat.com/user-terms.html")
                webVc.title = "Terms of Use"
                navigationController?.pushViewController(webVc, animated: true)
            }
                
            case .policy: do {
                let webVc = PhotoWebViewController(url: "http://www.surf-chat.com/privacy-policy.html")
                webVc.title = "Privacy Policy"
                navigationController?.pushViewController(webVc, animated: true)
            }
               
            case .about: do {
                let about = AboutViewController()
                navigationController?.pushViewController(about, animated: true)
            }
            default: break
            }
        }
    }
    
    @objc func updateData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: Cell
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
            if data.type == .vip {
                let vip = UserDefaults.standard.double(forKey: "sadAlbumVipTill")
                if vip > 0 {
                    let date = Date(timeIntervalSince1970: vip)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy"
                    let dateString = dateFormatter.string(from: date)
                    lab.text = data.title + " Till\n" + dateString
                }
            } else if data.type == .diamond {
                let diamonds = UserDefaults.standard.integer(forKey: "sadAlbumDiamondsBalance")
                if diamonds > 0 {
                    lab.text = data.title + "\n\(diamonds)"
                }
            }
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
        lab.numberOfLines = 2
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

// MARK: ViewModel
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
        
        let about = UserListModel()
        about.title = "About Us"
        about.type = .about
//        ver.title = "Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)"
        
        
        dataArr.append(vip)
        dataArr.append(coin)
        dataArr.append(agreement)
        dataArr.append(privacy)
        dataArr.append(about)
    }
}

class UserListModel {
    
    var title: String = ""
    var icon: String = ""
    var type: UserListType = .none
}

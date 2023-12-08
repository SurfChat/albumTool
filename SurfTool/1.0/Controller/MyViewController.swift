//
//  MyViewController.swift
//  SurfTool
//
//  Created by Phenou on 6/12/2023.
//

import UIKit
import StoreKit

enum UserListType {
    case none
    case vip
    case diamond
    case rate
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
        
        tableView.reloadData()
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
            return 210
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
               
            case .about: do {
                let about = AboutViewController()
                navigationController?.pushViewController(about, animated: true)
            }
                
            case .rate: do {
                if let windowScene = UIApplication.shared.windows.first?.windowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                }
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
        lab.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return lab
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none

        contentView.backgroundColor = .white
        
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.leading.top.equalTo(20)
        }
        
        contentView.addSubview(lab)
        lab.snp.makeConstraints { make in
            make.leading.equalTo(imgView.snp.trailing).offset(5)
            make.centerY.equalTo(imgView)
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
        
        let rate = UserListModel()
        rate.title = "Rate us"
        rate.icon = "rate"
        rate.type = .rate
        
        let about = UserListModel()
        about.title = "About Us"
        about.type = .about
        about.icon = "about"
        
        dataArr.append(vip)
        dataArr.append(coin)
        dataArr.append(rate)
        dataArr.append(about)
    }
}

class UserListModel {
    
    var title: String = ""
    var icon: String = ""
    var type: UserListType = .none
}

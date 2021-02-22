//
//  UserCell.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadziev on 1.2.21.
//

import UIKit
import SnapKit

protocol UserCellDelegate: class {
    func requestGameWith(user: User)
}

class UserCell: UITableViewCell {
    
//    private var activityIndicator: UIActivityIndicatorView = {
//        let activityIndicator = UIActivityIndicatorView(style: .medium)
//        activityIndicator.color = .red
//        return activityIndicator
//    }()
    
    lazy var lblUserName: UILabel = {
        var label = UILabel()
        //        label.textColor = .black
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private var startImage: UIImageView = {
        var image = UIImageView(image: UIImage(named: "start"))
        return image
    }()
    
    private var playerImage: UIImageView = {
        var image = UIImageView()
        return image
    }()
    
    private lazy var btnStart: UIButton = {
        var button = UIButton()
        button.addSubview(startImage)
        startImage.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        //        button.setTitle("Start Game", for: .normal)
        //        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        //        button.setTitleColor(UIColor(named: "systemOposite"), for: .normal)
        //        button.layer.borderWidth = 1.0
        //        button.layer.borderColor = UIColor.red.cgColor
        //        button.layer.cornerRadius = 5
        //        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(onStart), for: .touchUpInside)
        return button
    }()
    
    private lazy var holderView: UIView = {
        let view = UIView()
        view.layer.backgroundColor = UIColor.white.cgColor
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    private var user: User?
    weak var delegate: UserCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        //        let frame = CGRect.zero
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        layer.borderWidth = 0.5
//        layer.cornerRadius = 8
        layer.masksToBounds = true
        //        This is the same function from above
        //        separatorInset = .zero
        contentView.backgroundColor = .clear
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(holderView)
        contentView.addSubview(lblUserName)
        contentView.addSubview(btnStart)
       // contentView.addSubview(activityIndicator)
        contentView.addSubview(playerImage)
//        activityIndicator.isHidden = true
        
        lblUserName.snp.makeConstraints { (make) in
            make.leading.equalTo(playerImage.snp.trailing).offset(20)
           // make.center.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(btnStart.snp.leading).inset(10)
        }
        
        holderView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview()
        }
        
        btnStart.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(18)
            make.trailing.equalToSuperview().inset(20)
            make.size.equalTo(50)
        }
        
//        activityIndicator.snp.makeConstraints { (make) in
//            make.center.equalTo(btnStart).offset(20)
//        }
        
        playerImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(holderView).offset(20)
//            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(15)
            make.width.equalTo(50)
        }
    }
    
    @objc private func onStart() {
        guard let user = user else {return}
        delegate?.requestGameWith(user: user)
        btnStart.isHidden = true
//        activityIndicator.isHidden = false
//        activityIndicator.startAnimating()
    }
    
    func setData(user: User) {
        self.user = user
        lblUserName.text = user.username
        if let avatar = user.avatarImage {
        playerImage.image = UIImage(named: avatar)
        } else {
            playerImage.image = UIImage(named: "avatarOne")
        }
        btnStart.isHidden = false
    }
}

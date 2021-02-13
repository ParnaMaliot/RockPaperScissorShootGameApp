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
    
    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .red
        return activityIndicator
    }()
    
    lazy var lblUserName: UILabel = {
       var label = UILabel()
//        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
    
    private lazy var btnStart: UIButton = {
        var button = UIButton()
        button.setTitle("Start Game", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.setTitleColor(UIColor(named: "systemOposite"), for: .normal)
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(onStart), for: .touchUpInside)
        return button
    }()
    
    private var user: User?
    weak var delegate: UserCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
//        let frame = CGRect.zero
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        This is the same function from above
//        separatorInset = .zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(lblUserName)
        contentView.addSubview(btnStart)
        contentView.addSubview(activityIndicator)
        activityIndicator.isHidden = true
        
        lblUserName.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(btnStart.snp.leading).inset(10)
        }
        
        btnStart.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(2)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(70)
        }
        
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(btnStart)
        }
    }
    
    @objc private func onStart() {
        guard let user = user else {return}
        delegate?.requestGameWith(user: user)
        btnStart.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func setData(user: User) {
        self.user = user
        lblUserName.text = user.username
        btnStart.isHidden = false
    }
}

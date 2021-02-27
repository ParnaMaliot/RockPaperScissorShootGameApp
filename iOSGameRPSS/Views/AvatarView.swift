//
//  AvatarView.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadziev on 10.2.21.
//

import UIKit
import SnapKit

enum AvatarUIState {
    case loading
    case imageAndName
}

class AvatarView: UIView {
    
    var userName: String? {
        didSet {
            if state == .imageAndName {
            lblUserName.textColor = UIColor(hex: "4A6495")
                lblUserName.textAlignment = .left
            } else {
                lblUserName.textColor = .white
                lblUserName.textAlignment = .center
            }
            lblUserName.text = userName
        }
    }
    
    var image: String? {
        didSet {
            if let image = image {
                avatarImage.image = UIImage(named: image)
            }
        }
    }

    private lazy var lblUserName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
   private lazy var lblWinsLoses: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var avatarImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }()
    
    private var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 5
        return stackView
    }()
    
    var state: AvatarUIState
    
    init (state: AvatarUIState) {
        self.state = state
        super.init(frame: .zero)
        setupViews()
    }
    //This init is called only when the view is added in storyboard or xib
    //And the commented lines should be added
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
//        self.state = .imageAndName
//        super.init(coder: coder)
//        setupViews()
    }
    
    private func setupViews() {
        switch state {
        case .loading:
            addSubview(stackView)
            stackView.addArrangedSubview(lblUserName)
            stackView.addArrangedSubview(avatarImage)
            stackView.addArrangedSubview(lblWinsLoses)
            
        case .imageAndName:
            addSubview(horizontalStackView)
            horizontalStackView.addArrangedSubview(avatarImage)
            horizontalStackView.addArrangedSubview(lblUserName)
        }
        setupConstraints()
    }
    
    private func setupConstraints() {
        switch state {
        case .loading:
            stackView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            avatarImage.snp.makeConstraints { make in
                make.width.equalTo(85)
                make.height.equalTo(100)
            }
            
        case .imageAndName:
            horizontalStackView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            avatarImage.snp.makeConstraints { make in
                make.width.equalTo(35)
                make.height.equalTo(40)
            }
        }
    }
}

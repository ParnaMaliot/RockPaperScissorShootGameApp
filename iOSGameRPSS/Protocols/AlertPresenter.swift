//
//  AlertPresenter.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadjiev on 5.3.21.
//

import Foundation
import UIKit

protocol AlertPresenter {
    func showAlertWith(title: String, msg: String)
    func showGameRequestDeclinedRequest()
    func showErrorAlert(msg: String)
}

extension AlertPresenter where Self: UIViewController {
    func showAlertWith(title: String, msg: String) {
        showAlertWith(title: title, msg: msg)
    }
    
    func showErrorAlert(msg: String) {
        showAlertWith(title: nil, msg: "Your game request was declined")

    }
    
    func showGameRequestDeclinedRequest() {
        showAlertWith(title: nil, msg: "Your game request was declined")
    }
    
    private func showAlertWith(title: String?, msg: String?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
    }
}


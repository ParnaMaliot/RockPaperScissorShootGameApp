//
//  WelcomeViewController.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadziev on 1.2.21.
//

import UIKit
import FirebaseAuth
import GameplayKit

class WelcomeViewController: UIViewController {
    
    
    @IBOutlet weak var txtUserName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtUserName.layer.cornerRadius =  10
        txtUserName.layer.masksToBounds = true
        txtUserName.returnKeyType = .continue
        txtUserName.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        txtUserName.becomeFirstResponder()
    }
    
//    let avatars = ["avatarOne", "avatarTwo", "avatarThree"]
//
//    private func randomNumberAndAssignAvatar() -> String {
//        let randomIndex = Int(arc4random_uniform(UInt32(avatars.count)))
//        return avatars[randomIndex]
////        let shuffled = GKMersenneTwisterRandomSource.sharedRandom().arrayByShufflingObjects(in: avatars)
////        let firstRandom = shuffled[0]
////        let secondRandom = shuffled[1]
//    }

    
    @IBAction func onContinue(_ sender: UIButton) {
        guard let userName = txtUserName.text else {return}
        
        DataStore.shared.continueWithGuest(userName: userName) { [weak self] (user, error) in
            guard let self = self else {return}
            
            if let user = user {
                DataStore.shared.localUser = user
                self.performSegue(withIdentifier: "homeSegue", sender: nil)
            }
        }
    }
}

extension WelcomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

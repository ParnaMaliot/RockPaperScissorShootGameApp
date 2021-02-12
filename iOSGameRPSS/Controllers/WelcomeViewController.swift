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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        if Auth.auth().currentUser != nil, let id = Auth.auth().currentUser?.uid {
            DataStore.shared.getUserWith(id: id) { [weak self] (user, error) in
                guard let self = self else {return}

                if let user = user {
                    DataStore.shared.localUser = user
                    self.performSegue(withIdentifier: "homeSegue", sender: nil)
                }
            }
            return
        }
        DataStore.shared.continueWithGuest { [weak self] (user, error) in
            guard let self = self else {return}
            
            if let user = user {
                DataStore.shared.localUser = user
                self.performSegue(withIdentifier: "homeSegue", sender: nil)
            }
        }
    }
}

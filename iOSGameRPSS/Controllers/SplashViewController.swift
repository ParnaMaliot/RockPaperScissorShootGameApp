//
//  SplashViewController.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadjiev on 22.2.21.
//

import UIKit
import FirebaseAuth

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        checkForUser()
    }
    
    func checkForUser() {
        if Auth.auth().currentUser != nil, let id = Auth.auth().currentUser?.uid {
            DataStore.shared.getUserWith(id: id) { [weak self] (user, error) in
                guard let self = self else {return}

                if let user = user {
                    DataStore.shared.localUser = user
                    self.performSegue(withIdentifier: "homeSegue", sender: nil)
                    return
                }
                do {
                    try Auth.auth().signOut()
                    self.performSegue(withIdentifier: "welcomeSegue", sender: nil)
                } catch {
                    print(error.localizedDescription)
                }
            }
        } else {
            performSegue(withIdentifier: "welcomeSegue", sender: nil)
        }
    }
}

//
//  ResultViewController.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadjiev on 2.3.21.
//

import UIKit

class ResultViewController: UIViewController {
    
    @IBOutlet weak var winnerImage: UIImageView!
    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var lblWinner: UILabel!
    @IBOutlet weak var lblLoser: UILabel!
    
    var game: Game?
    var player: User?
    
    override func viewDidLoad() {
        if let winner = game?.winner {
            super.viewDidLoad()
            lblWinner.text = winner.username
            let loser = game?.players.filter({$0.id != winner.id}).first
            lblLoser.text = loser?.username
            winnerImage.image = UIImage(named: (winner.avatarImage)!)
        }
        

    }
    
    @IBAction func btnHome(_ sender: UIButton) {
        if let gameController = presentingViewController as? GameViewController {
            dismiss(animated: false) {
                gameController.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    @IBAction func btnReload(_ sender: UIButton) {
        
    }
    
    @IBAction func btnForward(_ sender: UIButton) {
        
    }
    
}

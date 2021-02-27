//
//  GameViewController.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadziev on 17.2.21.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var gameStatus: UILabel!
    @IBOutlet weak var Paper: UIButton!
    @IBOutlet weak var Scissors: UIButton!
    @IBOutlet weak var Rock: UIButton!
    @IBOutlet weak var Random: UIButton!
    
    var game: Game?

    override func viewDidLoad() {
        super.viewDidLoad()
        setGameStatusListener()
        gameStatus.text = game?.state.rawValue
    }
    
    private func setGameStatusListener() {
        guard let game = game else {return}
        
        DataStore.shared.setGameStateListener(game: game) { [weak self] (updatedGame, error) in
            if let updatedGame = updatedGame {
                self?.updateGame(updatedGame: updatedGame)
            }
        }
    }
    
//    func showAlert(title: String, message: String?, isExit: Bool = true) {
//        let alert = UIAlertController(title: "Alert", message: "User left the game", preferredStyle: .alert)
//        let confirm = UIAlertAction(title: "Ok", style: .default, handler: nil)
//        alert.addAction(confirm)
//        present(alert, animated: true, completion: nil)
//    }
    
    func updateGame(updatedGame: Game) {
        gameStatus.text = updatedGame.state.rawValue
        game = updatedGame
        if updatedGame.state == .finished {
            showAlertWith(title: "Congrats", message: "You won", isExit: false)
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        showAlertWith(title: nil, message: "Are you sure you want to exit?")
    }
    //isExit will be true every time the for the first player exits the game
    //He needs to update the game to finish
    private func showAlertWith(title: String?, message: String?, isExit: Bool = true) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let exit = UIAlertAction(title: "Exit", style: .destructive) { [weak self] _ in
            
            if let game = self?.game, isExit {
            DataStore.shared.updateGameStatus(game: self!.game!, newState: Game.GameState.finished.rawValue)
            }
            self?.dismiss(animated: true, completion: nil)
        }
        //We need to update the other player
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(exit)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnPaper(_ sender: UIButton) {
        
    }
    
    @IBAction func btnScissors(_ sender: UIButton) {
        
    }
    
    
    @IBAction func btnRock(_ sender: UIButton) {
        
    }
    
    @IBAction func btnRandom(_ sender: UIButton) {
        
    }
    
}

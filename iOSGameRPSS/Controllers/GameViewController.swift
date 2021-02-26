//
//  GameViewController.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadziev on 17.2.21.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var gameStatus: UILabel!
    
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
    
    func showAlert(title: String, message: String?, isExit: Bool = true) {
        let alert = UIAlertController(title: "Alert", message: "User left the game", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    
    func updateGame(updatedGame: Game) {
        gameStatus.text = updatedGame.state.rawValue
        game = updatedGame
        if updatedGame.state == .finished {
            showAlert(title: "Congrats", message: "You won", isExit: true)
        }
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to exit?", preferredStyle: .alert)
        
        let exit = UIAlertAction(title: "Exit", style: .destructive) { [weak self] _ in
            //We need to update the other player
            DataStore.shared.updateGameStatus(game: self!.game!, newState: Game.GameState.finished.rawValue)
            self?.dismiss(animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(exit)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}

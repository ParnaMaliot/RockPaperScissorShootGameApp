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
    var localPlayer: User?
    var opponent: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        setGameStatusListener()
        gameStatus.text = game?.state.rawValue
        if let game = game {
            shouldEnableButtons(enable: game.state == .inprogress)
        }
    }
    
    private func setGameStatusListener() {
        guard let game = game else {return}
        
        DataStore.shared.setGameStateListener(game: game) { [weak self] (updatedGame, error) in
            if let updatedGame = updatedGame {
                self?.updateGame(updatedGame: updatedGame)
            }
        }
    }
    
    func updateGame(updatedGame: Game) {
        shouldEnableButtons(enable: (updatedGame.state == .inprogress))
        gameStatus.text = updatedGame.state.rawValue
        game = updatedGame
        checkForWinner(game: updatedGame)
        if updatedGame.state == .finished {
            showAlertWith(title: "Congrats", message: "You won", isExit: false)
        }
    }
    
    private func shouldEnableButtons(enable: Bool) {
        Rock.isEnabled = enable
        Scissors.isEnabled = enable
        Paper.isEnabled = enable
        Random.isEnabled = enable
    }
    
    private func checkForWinner(game: Game) {
        guard let localUserId = DataStore.shared.localUser?.id, let opponentUserId = game.players.filter({$0.id != localUserId}).first?.id else {return}
        
        guard let localPlayer = game.players.filter({ $0.id == DataStore.shared.localUser?.id}).first,
              let opponent = game.players.filter({ $0.id != localPlayer.id }).first else { return }
               
        
        let moves = game.moves
        
        let myMove = moves[localUserId]
        let otherMove = moves[opponentUserId]
        
        if myMove == .idle && otherMove == .idle {
            //Both players haven't move yet
        } else if myMove == .idle {
            //Still waiting
        } else if myMove == .idle {
            //Still waiting
        } else {
            //We have both moves
            if let mMove = myMove, let oMove = otherMove {
                //This will succeed only if the local user is a winner
                //Other user will get a listener for the game with updated winner property
                if mMove > oMove {
                    //Winner is mMove
                    DataStore.shared.removeGameListener()
                    self.game?.winner = game.players.filter({$0.id == localUserId}).first
                    DataStore.shared.updateGameMoves(game: self.game!)
                    self.continueToResults()
                }
//                else {
//                    //Winner is oMove
//                    //game.winner = opponentUser
//                    self.game?.winner = opponent
//                }
            }
        }
    }
    
    private func continueToResults() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
        controller.game = game
        navigationController?.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)

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
        guard let localUserId = DataStore.shared.localUser?.id, var game = game else {return}
        
        game.moves[localUserId] = .paper
        DataStore.shared.updateGameMoves(game: game)
        shouldEnableButtons(enable: false)
            }
    
    @IBAction func btnScissors(_ sender: UIButton) {
        guard let localUserId = DataStore.shared.localUser?.id, var game = game  else {return}
        
        game.moves[localUserId] = .scissors
        shouldEnableButtons(enable: false)
    }
    
    
    @IBAction func btnRock(_ sender: UIButton) {
        guard let localUserId = DataStore.shared.localUser?.id, var game = game  else {return}
        
        game.moves[localUserId] = .rock
        shouldEnableButtons(enable: false)
    }
    
    @IBAction func btnRandom(_ sender: UIButton) {
        guard let localUserId = DataStore.shared.localUser?.id, var game = game  else {return}
        
        var choices: [Moves] = Moves.allCases.filter {$0 != .idle}
        let move = choices.randomElement()
        
        game.moves[localUserId] = move
        DataStore.shared.updateGameMoves(game: game)
        shouldEnableButtons(enable: false)
        
        //More swifty way
        //games.moves[localUserId] = move.allCases.filter {$0 != .idle}.randomElement()
    }
}

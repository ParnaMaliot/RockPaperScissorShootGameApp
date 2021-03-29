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
    @IBOutlet weak var topHand: UIImageView!
    @IBOutlet weak var bottomHand: UIImageView!
    @IBOutlet weak var bottomHandConstraint: NSLayoutConstraint!
    @IBOutlet weak var topHandConstraint: NSLayoutConstraint!
    @IBOutlet weak var opponentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var myHandHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bloodImage: UIImageView!
    
    var game: Game?
    var localPlayer: User?
    var opponent: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bloodImage.transform = CGAffineTransform(scaleX: 0, y: 0)
        setConstraintsForSmallerDevices()
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
        animateMoves(game: updatedGame)
        return
//        checkForWinner(game: updatedGame)
        
        if updatedGame.state == .finished && game?.winner == nil {
            DataStore.shared.removeGameListener()
            game?.winner = updatedGame.players.filter({$0.id == DataStore.shared.localUser?.id}).first
            DataStore.shared.updateGameMoves(game: self.game!)
            continueToResults()
        }
    }
    
    private func shouldEnableButtons(enable: Bool) {
        Rock.isEnabled = enable
        Scissors.isEnabled = enable
        Paper.isEnabled = enable
        Random.isEnabled = enable
    }
    
    private func animateMoves(game: Game) {
        guard let localUserId = DataStore.shared.localUser?.id, let opponentUserId = game.players.filter({$0.id != localUserId}).first?.id else {return}
        
        let moves = game.moves
        let myMove = moves[localUserId]
        let otherMove = moves[opponentUserId]
        
        if myMove != .idle && otherMove != .idle {
            //We will animate both hands at the same time back on board
            animateMyHandTo(move: myMove)
            animateOtherHandTo(move: otherMove)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.bottomHandConstraint.constant = Moves.minimumY(isOpponent: false)
                self.topHandConstraint.constant = Moves.minimumY(isOpponent: true)
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                } completion: { finished in
                    if finished {
                        self.checkForWinner(game: game)
                    }
                    
                }
            }
            return
        }
    }
    
    private func animateHandTo(move: Moves?, isMyHand: Bool) {
        guard let move = move, move != .idle else {return}

        if isMyHand {
            self.bottomHandConstraint.constant = Moves.maximumY
        } else {
            self.topHandConstraint.constant = Moves.maximumY
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        } completion: { finished in
            if finished {
                if isMyHand {
                    self.bottomHand.image = UIImage(named: move.imageName(isOpponent: !isMyHand))
                } else {
                    self.topHand.image = UIImage(named: move.imageName(isOpponent: !isMyHand))
                }
            }
        }

        
    }
    
    private func animateMyHandTo(move: Moves?) {
        guard let move = move, move != .idle else {return}
        
        //If the bottom line doesn't work add it inside the UIView.animate closure
        bottomHandConstraint.constant = Moves.maximumY
        
        UIView.animate(withDuration: 0.2) {
            //Closure for animation
            self.view.layoutIfNeeded()
        } completion: { finished in
            //closure when animation is done, finished flag argument (flag == bool)
            if finished {
                self.bottomHand.image = UIImage(named: move.imageName(isOpponent: false))
            }
        }
    }
    
    private func animateOtherHandTo(move: Moves?) {
        guard let move = move, move != .idle else {return}
        
        topHandConstraint.constant = Moves.maximumY
        
        UIView.animate(withDuration: 0.2) {
            //Closure for animation
            self.view.layoutIfNeeded()
        } completion: { finished in
            //closure when animation is done, finished flag argument (flag == bool)
            if finished {
                self.topHand.image = UIImage(named: move.imageName(isOpponent: false))
            }
        }
        
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
            animateHandTo(move: myMove, isMyHand: true)
            animateHandTo(move: otherMove, isMyHand: false)

        } else if myMove == .idle {
            //Still waiting
        } else if otherMove == .idle {
            //Still waiting
        } else {
            //We have both moves
            if let mMove = myMove, let oMove = otherMove {
                //This will succeed only if the local user is a winner
                //Other user will get a listener for the game with updated winner property
                let space = abs((topHand.frame.origin.y + topHand.frame.height) - bottomHand.frame.origin.y)

                if mMove > oMove {
                    //Winner is mMove
                    UIView.animate(withDuration: 0.5) {
                        self.bottomHand.transform = CGAffineTransform(translationX: 0, y: -space)
                    } completion: { finished in
                        if finished {
                            UIView.animate(withDuration: 0.5) {
                                self.bloodImage.transform = .identity
                                self.bottomHand.transform = .identity
                            } completion: { finished in
                                if finished {
                                    self.setWinner(game: game)
                                }
                            }
                        }
                    }
                }
                else {
                    UIView.animate(withDuration: 0.5) {
                        self.topHand.transform = CGAffineTransform(translationX: 0, y: +space)
                    } completion: { finished in
                        if finished {
                            UIView.animate(withDuration: 0.5) {
                                self.bloodImage.transform = .identity
                                self.topHand.transform = .identity
                            } completion: { finished in
                                if finished {
                                    //self.setWinner(game: game)
                                }
                            }
                        }
                    }
                    
                    
                    //Winner is oMove
                    //game.winner = opponentUser
                    //self.game?.winner = opponent
                    if let _ = game.winner {
                        continueToResults()
                    }
                }
            }
        }
    }
    
    private func setWinner(game: Game) {
        guard let localUserId = DataStore.shared.localUser?.id else {return}
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        DataStore.shared.removeGameListener()
        self.game?.winner = game.players.filter({$0.id == localUserId}).first
        self.game?.state = .finished
        DataStore.shared.updateGameMoves(game: self.game!)
        self.continueToResults()
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
        sender.isSelected = true
        pickedMove(.paper)
    }
    
    @IBAction func btnScissors(_ sender: UIButton) {
        sender.isSelected = true
        pickedMove(.scissors)
        
    }
    
    @IBAction func btnRock(_ sender: UIButton) {
        sender.isSelected = true
        pickedMove(.rock)
    }
    
    @IBAction func btnRandom(_ sender: UIButton) {
        guard let localUserId = DataStore.shared.localUser?.id, var game = game  else {return}
        
        var choices: [Moves] = Moves.allCases.filter {$0 != .idle}
        let move = choices.randomElement()
        
        game.moves[localUserId] = move
        DataStore.shared.updateGameMoves(game: game)
        shouldEnableButtons(enable: false)
        selectButtonForMove(move: move!)
        pickedMove(move!)
        //More swifty way
        //games.moves[localUserId] = move.allCases.filter {$0 != .idle}.randomElement()
    }
    
    private func selectButtonForMove(move: Moves) {
        switch move {
        case .idle:
            return
        case .paper:
            Paper.isSelected = true
        case .scissors:
            Scissors.isSelected = true
        case .rock:
            Rock.isSelected = true
        }
    }
    
    private func pickedMove(_ move: Moves) {
        guard let localUserId = DataStore.shared.localUser?.id, var game = game else { return }
        game.moves[localUserId] = move
        DataStore.shared.updateGameMoves(game: game)
        shouldEnableButtons(enable: false)
    }
    
    private func setConstraintsForSmallerDevices() {
        if DeviceType.isIphone8OrSmaller {
            myHandHeightConstraint.constant = 320
            opponentHeightConstraint.constant = 320
        } else if DeviceType.isIphoneXOrBigger {
            myHandHeightConstraint.constant = 420
            opponentHeightConstraint.constant = 420
        }
    }
}

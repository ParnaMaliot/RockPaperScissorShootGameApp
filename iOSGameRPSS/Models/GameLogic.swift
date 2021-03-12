//
//  GameLogic.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadjiev on 28.2.21.
//

import Foundation
import UIKit


enum Moves: String, Comparable, Codable, CaseIterable {
    case rock, scissors, paper, idle
    
    static func < (lhs: Moves, rhs: Moves) -> Bool {
        switch (lhs, rhs) {
        case (.rock, .paper):
            return true
        case (.paper, .scissors):
            return true
        case (.scissors, .rock):
            return true
        case (.idle, .paper):
            return true
        case (.idle, .rock):
            return true
        case (.idle, .scissors):
            return true
        default:
            return false
        }
    }
    
    static func == (lhs: Moves, rhs: Moves) -> Bool {
        switch (lhs, rhs) {
        case (.rock, .rock):
            return true
        case (.scissors, .scissors):
            return true
        case (.paper, .paper):
            return true
        case (.idle, .idle):
            return true
        default:
            return false
        }
    }
    //Top most Y coordinate for both hands (hidden))
    static var maximumY: CGFloat {
        return -500
    }
    //Bottom most Y coordinate for both hands (fully show)
    static func minimumY(isOpponent: Bool) -> CGFloat {
        return isOpponent ? -90 : -30
    }
    
    func imageName(isOpponent: Bool) -> String {
        switch self {
        case .idle:
            return isOpponent ? "steady_top" : "steady_ bot"
        case .paper:
            return isOpponent ? "paper_top" : "paper bot"
        case .rock:
            return isOpponent ? "rock_top" : "rock_ bot"
        case .scissors:
            return isOpponent ? "scissors_top" : "scissors_ bot"

        }
    }
}


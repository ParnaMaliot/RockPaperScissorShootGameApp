//
//  GameLogic.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadjiev on 28.2.21.
//

import Foundation


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
}


//
//  GameRequest.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadziev on 3.2.21.
//

import Foundation

struct GameRequest: Codable {
    var id: String
    var from: String //User Id of the uesr who initiated the request
    var to: String //User id of the user who was invited to play
    var createdAt: TimeInterval
}

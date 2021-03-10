//
//  File.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadjiev on 10.3.21.
//

import Foundation

class PushNotificationManager {
    static let shared = PushNotificationManager()
    private init() {}
    
   private(set) var gameRequest: GameRequest?
    
    func handlePushNotification(dict: [String:Any]) {
        guard let requestId = dict["id"] as? String else {
            return
        }
        
        DataStore.shared.getGameRequestWithId(id: requestId) { request, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.gameRequest = request
        }
    }
    
    func getGameRequest() -> GameRequest? {
//        let request = gameRequest
//        gameRequest = nil
        return gameRequest
    }
    
    func clearVariable() {
        gameRequest = nil
    }
}

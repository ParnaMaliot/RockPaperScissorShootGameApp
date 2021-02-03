//
//  DataStore+GameRequests.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadziev on 3.2.21.
//

import Foundation

extension DataStore {
    func startGameRequest(userId: String, completion: @escaping(_ request: GameRequest?, _ error: Error?) -> Void)  {
        let requestRef = database.collection(FirebaseCollections.gameRequests.rawValue).document()
        let gameRequest = createGameRequest(toUser: userId, id: requestRef.documentID)
        
        do {
            try requestRef.setData(from: gameRequest, completion: {error in
                if let error = error {
                    completion(nil, error)
                }
                completion(gameRequest, nil)
            })
        } catch {
            completion(nil, error)
        }
    }
    
    private func createGameRequest(toUser: String, id: String) -> GameRequest? {
        guard let localUserId = localUser?.id else {return nil}
        return GameRequest(id: id,
                           from: localUserId,
                           to: toUser,
                           createdAt: Date().toMiliseconds())
    }
    
    func setGameRequestListener() {
        if gameRequestListener != nil {
            removeGameRequestListener()
        }
        guard let localUserId = localUser?.id else {return}
        gameRequestListener = database
            .collection(FirebaseCollections.gameRequests.rawValue)
            .whereField("to", isEqualTo: localUserId)
            .addSnapshotListener { (snapshot, error) in
                if let snapshot = snapshot, let document = snapshot.documents.first {
                    do {
                        let gameRequest = try document.data(as: GameRequest.self)
                        print("New Game Request with " + (gameRequest?.from ?? ""))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
    }
    
    func removeGameRequestListener() {
        gameRequestListener?.remove()
        gameRequestListener = nil
    }
}

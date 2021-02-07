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
                           createdAt: Date().toMiliseconds(), fromUserName: localUser?.username)
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
                        NotificationCenter.default.post(name: Notification.Name("DidReceiveGameRequestNotification"), object: nil, userInfo: ["GameRequests" : gameRequest as Any])
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
    
    func setGameRequestDeletionListener() {
        if gameRequestDeletionListener != nil {
            removeGameRequestDeletionListener()
        }
        guard let localUserId = localUser?.id else {return}
        gameRequestDeletionListener = database
            .collection(FirebaseCollections.gameRequests.rawValue)
            .whereField("from", isEqualTo: localUserId)
            .addSnapshotListener { (snapshot, error) in
                if let snapshot = snapshot {
                    do {
                        print("Game requests count:  \(snapshot.documents.count)")
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
    }
    
    func removeGameRequestDeletionListener() {
        gameRequestDeletionListener?.remove()
        gameRequestDeletionListener = nil
    }
    
    func deleteGameRequest(gameRequest: GameRequest) {
        let gameRequestRef = database.collection(FirebaseCollections.gameRequests.rawValue).document(gameRequest.id)
        gameRequestRef.delete()
    }
}

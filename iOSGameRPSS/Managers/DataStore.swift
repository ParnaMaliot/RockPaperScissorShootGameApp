//
//  DataStore.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadziev on 1.2.21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class DataStore {
    
    enum FirebaseCollections: String {
        case users
        case gameRequests
    }
    
    static let shared = DataStore()
    let database = Firestore.firestore()
    var localUser: User? {
        didSet {
            if localUser?.avatarImage == nil {
              //  localUser?.avatarImage = avatars.randomElement()
                localUser?.setRandomImage()
                guard let localUser = localUser else {return}
                DataStore.shared.saveUser(user: localUser) { (_, _) in
                }
            }
        }
    }
    var usersListener: ListenerRegistration?
    var gameRequestListener: ListenerRegistration?
    var gameRequestDeletionListener: ListenerRegistration?

    init() {}
    
    func continueWithGuest(completion: @escaping(_ user: User?, _ error: Error?) -> Void) {
        Auth.auth().signInAnonymously { (result, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            if let currentUser = result?.user {
                let localUser = User.createUser(id: currentUser.uid, username: "Parna")
                self.saveUser(user: localUser, completion: completion)
            }
        }
    }
    
    func saveUser(user: User, completion: @escaping(_ user: User?, _ error: Error?) -> Void) {
        let userRef = database.collection(FirebaseCollections.users.rawValue).document(user.id!)
        do {
            try userRef.setData(from: user) { error in
                completion(user, error)
            }
        } catch {
            print(error.localizedDescription)
            completion(nil, error)
        }
    }
    
    func getAllUsers(completion: @escaping(_ users: [User]?, _ error: Error?) -> Void) {
        let usersRef = database.collection(FirebaseCollections.users.rawValue)
        usersRef.getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            if let snapshot = snapshot {
                do {
                    let users = try snapshot.documents.compactMap({ try $0.data(as: User.self) })
                    completion(users, nil)
                } catch (let error) {
                    completion(nil, error)
                }
            }
        }
    }
    
    func getUserWith(id: String, completion: @escaping(_ users: User?, _ error: Error?) -> Void) {
        let userRef = database.collection(FirebaseCollections.users.rawValue).document(id)
        
        userRef.getDocument(completion: {(document, error) in
            if let document = document {
                do {
                    let user = try document.data(as: User.self)
                    completion(user, nil)
                } catch {
                    completion(nil, error)
                }
            }
        })
    }
    
    func setUsersListener(completion: @escaping() -> Void) {
        if usersListener != nil {
            usersListener?.remove()
            usersListener = nil
        }
        let userRef = database.collection(FirebaseCollections.users.rawValue)
        usersListener = userRef.addSnapshotListener { (snapshot, error) in
            if let snapshot = snapshot, snapshot.documents.count > 0 {
                completion()
            }
        }
    }
    
    func removeusersListeners() {
        usersListener?.remove()
        usersListener = nil
    }
}

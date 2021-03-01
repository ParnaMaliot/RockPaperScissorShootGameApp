//
//  DataStore.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadziev on 1.2.21.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseMessaging

class DataStore {
    
    enum FirebaseCollections: String {
        case users
        case gameRequests
        case games
    }
    
    static let shared = DataStore()
    let database = Firestore.firestore()
    var localUser: User? {
        didSet {
            //            if localUser?.avatarImage == nil {
            //              //  localUser?.avatarImage = avatars.randomElement()
            //                localUser?.setRandomImage()
            if localUser?.deviceToken == nil {
                setPushToken()
            }
            guard let localUser = localUser else {return}
            DataStore.shared.saveUser(user: localUser) { (_, _) in
            }
            //            }
        }
    }
    var usersListener: ListenerRegistration?
    var gameRequestListener: ListenerRegistration?
    var gameRequestDeletionListener: ListenerRegistration?
    var gameListener: ListenerRegistration?
    var gameStatusListener: ListenerRegistration?
    var selectedHandListener: ListenerRegistration?
    
    init() {}
    
    func setPushToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                self.localUser?.deviceToken = token
                self.saveUser(user: self.localUser!) {(_,_) in
                    
                }
            }
        }
    }
    
    func checkForExistingUserName( _ userName: String, _ completion: @escaping(_ exists: Bool, _ error: Error?) -> Void) {
        let userNameRef = self.database.collection(FirebaseCollections.users.rawValue).whereField("username", isEqualTo: userName)
        
        userNameRef.getDocuments { (snapshot, error)  in
            if let snapshot = snapshot?.documents, snapshot.count == 0 {
                completion(false, nil)
                return
            }
            completion(true, nil)
        }
    }
    
    func continueWithGuest(userName: String, completion: @escaping(_ user: User?, _ error: Error?) -> Void) {
        
        Auth.auth().signInAnonymously { (result, error) in
            if let currentUser = result?.user {
                let localUser = User.createUser(id: currentUser.uid, username: userName)
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

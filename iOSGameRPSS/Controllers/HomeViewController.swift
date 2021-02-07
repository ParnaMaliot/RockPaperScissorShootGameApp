//
//  HomeViewController.swift
//  iOSGameRPSS
//
//  Created by Igor Parnadziev on 1.2.21.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Welcome " + (DataStore.shared.localUser?.username ?? "")
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveGameRequest(_:)), name: Notification.Name("DidReceiveGameRequestNotification"), object: nil)
        setupTableView()
        getUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataStore.shared.setUsersListener { [weak self] in
            guard let self = self else {return}
            self.getUsers()
        }
        DataStore.shared.setGameRequestListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DataStore.shared.removeusersListeners()
        DataStore.shared.removeGameRequestListener()
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .singleLine
        tableView.dataSource = self
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
    }
    
    @objc private func didReceiveGameRequest( _ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String : GameRequest] else {return}
        guard let gameRequest = userInfo["GameRequest"] else {return}
        
        let fromUserName = gameRequest.fromUserName ?? ""
        let alert = UIAlertController(title: "Game Request", message: "\(fromUserName) invited you for a game", preferredStyle: .alert)
        
        let accept = UIAlertAction(title: "Accept", style: .default) { _ in
            self.declineRequest(gameRequest: gameRequest)
        }
        let declne = UIAlertAction(title: "Decline", style: .cancel) { _ in
            self.declineRequest(gameRequest: gameRequest)
        }
        
        alert.addAction(accept)
        alert.addAction(declne)
        present(alert, animated: true, completion: nil)
    }
    
    private func getUsers() {
        DataStore.shared.getAllUsers { [weak self] (users, error) in
            guard let self = self else {return}
            if let users = users {
                self.users = users.filter({$0.id != DataStore.shared.localUser?.id})
                self.tableView.reloadData()
            }
        }
    }
    
    private func declineRequest(gameRequest: GameRequest) {
        DataStore.shared.deleteGameRequest(gameRequest: gameRequest)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier) as! UserCell
        let user = users[indexPath.row]
        cell.setData(user: user)
        cell.delegate = self
        return cell
    }
}

extension HomeViewController: UserCellDelegate {
    func requestGameWith(user: User) {
        guard let userId = user.id else {return}
        DataStore.shared.startGameRequest(userId: userId) { (user, error) in
            DataStore.shared.setGameRequestDeletionListener()
        }
    }
}

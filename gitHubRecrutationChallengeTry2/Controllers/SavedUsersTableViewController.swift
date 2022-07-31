//
//  SavedUsersTableViewController.swift
//  gitHubRecrutationChallengeTry2
//
//  Created by Tomasz Kubiak on 7/28/22.
//

import UIKit
import RealmSwift

class SavedUsersTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let localRealm = try! Realm()
    
    private lazy var dataStore = ImageDataStore()
    private lazy var loadingQueue = OperationQueue()
    private lazy var loadingOperations = [IndexPath : DataLoadOperation]()
    
    private var retrivedUsers: [UserModel] = []
    
    override func viewDidLoad() {
        title = "Saved Users"
        super.viewDidLoad()
//        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        getSavedUsers()
        tableView.reloadData()
    }
    func getSavedUsers() {
        let array = Array(localRealm.objects(RealmUserModel.self).sorted(byKeyPath: "userName", ascending: true))
        for realmUser in array {
            let user = UserModel(realmUserModel: realmUser)
            retrivedUsers.append(user)
        }
        dataStore = ImageDataStore(userModels: retrivedUsers)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? UserDetailViewController {
            if let sender = sender as? UserCell {
                destinationVC.image = sender.userAvatarImage.image
                if let user = sender.getUserModel() {
                    destinationVC.assignUserModel(user: user)
                }else {
                    fatalError("Failed at retrieving user model from the cell")
                }
            }
        }
    }
}

extension SavedUsersTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? UserCell else { return }
        let updateCellClosure: (UIImage?) -> () = { [unowned self] (image) in
            cell.configureCell(image)
            self.loadingOperations.removeValue(forKey: indexPath)
        }
        if let dataLoader = loadingOperations[indexPath] {
            if let image = dataLoader.image {
                cell.configureCell(image)
                loadingOperations.removeValue(forKey: indexPath)
            } else {
                dataLoader.loadingCompleteHandler = updateCellClosure
            }
        } else {
            if let dataLoader = dataStore.loadImage(at: indexPath.row) {
                dataLoader.loadingCompleteHandler = updateCellClosure
                loadingQueue.addOperation(dataLoader)
                loadingOperations[indexPath] = dataLoader
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let dataLoader = loadingOperations[indexPath] {
            dataLoader.cancel()
            loadingOperations.removeValue(forKey: indexPath)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let cell = tableView.cellForRow(at: indexPath) as? UserCell {
//            performSegue(withIdentifier: "ToSavedUserDetails", sender: cell)
//        }
    }
}

extension SavedUsersTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return retrivedUsers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedUserCell", for: indexPath) as! UserCell
        cell.configureCell(user: retrivedUsers[indexPath.row])
        let updateCellClosure: (UIImage?) -> () = { [unowned self] (image) in
            cell.configureCell(image)
            self.loadingOperations.removeValue(forKey: indexPath)
        }
        if let dataLoader = loadingOperations[indexPath] {
            if let image = dataLoader.image {
                cell.configureCell(image)
                loadingOperations.removeValue(forKey: indexPath)
            } else {
                dataLoader.loadingCompleteHandler = updateCellClosure
            }
        } else {
            if let dataLoader = dataStore.loadImage(at: indexPath.row) {
                dataLoader.loadingCompleteHandler = updateCellClosure
                loadingQueue.addOperation(dataLoader)
                loadingOperations[indexPath] = dataLoader
            }
        }
        return cell
    }
    
    
}

extension SavedUsersTableViewController: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let _ = loadingOperations[indexPath] { return }
            if let dataLoader = dataStore.loadImage(at: indexPath.row) {
                loadingQueue.addOperation(dataLoader)
                loadingOperations[indexPath] = dataLoader
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let dataLoader = loadingOperations[indexPath] {
                dataLoader.cancel()
                loadingOperations.removeValue(forKey: indexPath)
            }
        }
    }
    
}

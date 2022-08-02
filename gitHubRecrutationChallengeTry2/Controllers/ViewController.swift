//
//  ViewController.swift
//  gitHubRecrutationChallengeTry2
//
//  Created by Tomasz Kubiak on 7/21/22.
//

import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var dataStore = ImageDataStore()
    private lazy var loadingQueue = OperationQueue()
    private lazy var loadingOperations = [IndexPath : DataLoadOperation]()
    
    private var userListManager = UserListManager()
    private var retrievedUsers: [UserModel] = []
    private var currentSearchQuery: String?
    private var isUserSearchActive: Bool = false
    private var currentSearchPage: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userListManager.delegate = self
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        title = "Search Github for users"
        searchBar.showsCancelButton = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? UserDetailViewController {
            if let sender = sender as? UserCell {
                if let user = sender.getUserModel(), let image = sender.userAvatarImage.image {
                    destinationVC.assignUserData(user: user, image: image)
                } else {
                    fatalError("Failed at retrieving user model from the cell")
                }
            }
            
        }
    }
}

extension ViewController: LoadUsersCellDelegate {
    
    func loadMoreUsers() {
        print("loading more users")
        if let username = currentSearchQuery, isUserSearchActive == true, let page = currentSearchPage {
            currentSearchPage = page + 1
            userListManager.fetchUsers(username: username, page: currentSearchPage)
            
        }
    }
}

extension ViewController: UITableViewDataSourcePrefetching {
    
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

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let username = searchBar.text {
            currentSearchQuery = username
            userListManager.fetchUsers(username: username)
            self.isUserSearchActive = false
        }
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        retrievedUsers.removeAll()
        self.dataStore = ImageDataStore()
        loadingQueue.cancelAllOperations()
        loadingOperations.removeAll()
        tableView.reloadData()
        
    }
}

extension ViewController: UITableViewDelegate {
        
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      
        guard let cell = cell as? UserCell else {
            return
        }
        
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
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return retrievedUsers.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < retrievedUsers.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
            cell.configureCell(user: retrievedUsers[indexPath.row])
            cell.isUserInteractionEnabled = true
        return cell
        } else {
            if retrievedUsers.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
                cell.configureCell()
                cell.isUserInteractionEnabled = false
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "LoadUsersCell", for: indexPath) as! LoadUsersCell
                cell.isUserInteractionEnabled = true
                cell.delegate = self
                return cell
            }
        }
        
    }
}


extension ViewController: UserDataManagerDelegate {
    func didFailWithErrors(error: Error) {
        DispatchQueue.main.async {
            print("userDataManagerDelegate did fail with Errors:")
            print(error)
        }
    }
    
    func didUpdateUsers(_ userListManager: UserListManager, users: [UserModel]) {
        
        if self.isUserSearchActive == true {
            var tempUsers: [UserModel] = []
            for user in users {
                if !retrievedUsers.contains(where: {$0 == user}) {
                    tempUsers.append(user)
                }
            }
            retrievedUsers.append(contentsOf: tempUsers)
            self.dataStore.appendUsers(userModels: tempUsers)
        } else {
            self.currentSearchPage = 1
            self.retrievedUsers = users
            self.dataStore = ImageDataStore(userModels: users)
            self.isUserSearchActive = true
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

//
//  ViewController.swift
//  gitHubRecrutationChallengeTry2
//
//  Created by Tomasz Kubiak on 7/21/22.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var favoritesButton: UIButton!
    
    let localRealm = try! Realm()
    
    private lazy var dataStore = ImageDataStore()
    private lazy var loadingQueue = OperationQueue()
    private lazy var loadingOperations = [IndexPath : DataLoadOperation]()
    
    private var userListManager = UserListManager()
    private var retrievedUsers: [UserModel] = []
    private var currentSearchQuery: String?
    private var isSearching: Bool = false
    private var currentSearchPage: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userListManager.delegate = self
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
    }
    
    
    @IBAction func favoritesButtonTapped(_ sender: Any) {
        favoritesButton.setTitle("Favourite Users", for: .normal)
        retrievedUsers = []
        dataStore = ImageDataStore()
        loadingQueue = OperationQueue()
        loadingOperations = [:]
        let array = Array(localRealm.objects(RealmUserModel.self).sorted(byKeyPath: "userName", ascending: true))
        var users: [UserModel] = []
        
        for item in array {
            let user = UserModel(userName: item.userName, avatarUrl: item.avatarUrl, imageModel: ImageModel(url: item.avatarUrl))
            users.append(user)
        }
        
        retrievedUsers.append(contentsOf: users)
        dataStore.appendUsers(userModels: users)
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? UserDetailViewController {
            if let sender = sender as? UserCell {
//                destinationVC.userAvatarImage.image = sender.userAvatarImage.image
//                destinationVC.userNameLabel.text = sender.userNameLabel.text
                destinationVC.image = sender.userAvatarImage.image
                if let user = sender.getUserModel() {
                    destinationVC.assignUserModel(user: user)
                } else {
                    fatalError("Failed at retrieving user model from the cell")
                }
            }
            
        }
        // Pass the selected object to the new view controller.
    }
    

    
}

extension ViewController: LoadUsersCellDelegate {
    func loadMoreUsers() {
        print("loading more users")
        if let username = currentSearchQuery, isSearching == true, let page = currentSearchPage {
            currentSearchPage = page + 1
            userListManager.fetchUsers(username: username, page: page + 1)
        }
    }
}

extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let _ = loadingOperations[indexPath] { return }
//            else craete a dataLoader, with datastore method loadimage at indexPath.row
                    if let dataLoader = dataStore.loadImage(at: indexPath.row) {
//                        if sucssesful add operation to loading que
                        loadingQueue.addOperation(dataLoader)
//                        assign operation to position in loading operation for the selected indexPath
                        loadingOperations[indexPath] = dataLoader
                    }
        }
        
    }
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
//        go through all of the indexPath that are requested thorugh the protocol
        for indexPath in indexPaths {
//            if data loader exists for this index path
                if let dataLoader = loadingOperations[indexPath] {
//                    cancel data loader
                    dataLoader.cancel()
//                    remove loading operation from the dictionary
                    loadingOperations.removeValue(forKey: indexPath)
                }
            }
    }
    
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search button clicked!")
        if let username = searchBar.text {
            currentSearchQuery = username
            userListManager.fetchUsers(username: username)
            self.isSearching = false
        }
        searchBar.resignFirstResponder()
    }
}

// MARK: -table view delegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        code failes when you double click on load more users button hehe
        if let cell = tableView.cellForRow(at: indexPath) as? UserCell {
            performSegue(withIdentifier: "ToUserDetail", sender: cell)
            print("selected row is \(indexPath.row), associated user is: \(retrievedUsers[indexPath.row].userName)")
        }
//        push new controller modally to show the user details.
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //        with prefetch it this function has to handle following cases:
        //        1. data has been loaded via prefetch request andis ready to be displayed
        //        2. Data is currently being prefetched but is not yet avaliable
        //        3. Data has been not requested.
        guard let cell = cell as? UserCell else {
//            print("Failed to cast cell as userCell in willDisplay method")
            return
        }
        
//        completion handler for the cell once the data has been loaded
        let updateCellClosure: (UIImage?) -> () = { [unowned self] (image) in
            cell.configureCell(image)
            self.loadingOperations.removeValue(forKey: indexPath)
        }
//      Check if data loader for this index path exists
        if let dataLoader = loadingOperations[indexPath] {
//           check if data is loaded and is ready to be displayed
            if let image = dataLoader.image {
//              display image in cell
                cell.configureCell(image)
//              remove loading operation for this cell
                loadingOperations.removeValue(forKey: indexPath)
            } else {
//              data has not been loaded - assign a completion handler to update the cell on download completion
                dataLoader.loadingCompleteHandler = updateCellClosure
            }
        } else {
//            data loader for index path does not exist - create it!
            if let dataLoader = dataStore.loadImage(at: indexPath.row) {
                dataLoader.loadingCompleteHandler = updateCellClosure
                loadingQueue.addOperation(dataLoader)
                loadingOperations[indexPath] = dataLoader
            }
        }
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//      Cancel and dispose for existing data loaders for cells that did end displaying (maybe ceal dataStore too?
        if let dataLoader = loadingOperations[indexPath] {
            dataLoader.cancel()
            loadingOperations.removeValue(forKey: indexPath)
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if retrievedUsers.count == 0 {
            return 1
        } else {
            return retrievedUsers.count+1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < retrievedUsers.count {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        
        if retrievedUsers.count == 0 {
            cell.configureCell()
            return cell
        } else {
        cell.configureCell(user: retrievedUsers[indexPath.row])
        return cell
        }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadUsersCell", for: indexPath) as! LoadUsersCell
            cell.delegate = self
            return cell
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
        DispatchQueue.main.async {
            print("Did updated the users successfully")
            if self.isSearching == true {
                self.retrievedUsers.append(contentsOf: users)
                self.dataStore.appendUsers(userModels: users)
                self.tableView.reloadData()
            } else {
                self.currentSearchPage = 1
                self.retrievedUsers = users
                self.dataStore = ImageDataStore(userModels: users)
                self.isSearching = true
                self.tableView.reloadData()
                
            }
        }
        
        
    }
}

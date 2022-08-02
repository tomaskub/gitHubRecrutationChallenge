//
//  UserListManager.swift
//  gitHubRecrutationChallengeTry2
//
//  Created by Tomasz Kubiak on 7/21/22.
//

import Foundation
protocol UserDataManagerDelegate {
    func didUpdateUsers(_ userListManager: UserListManager, users: [UserModel])
    func didFailWithErrors(error: Error)
}

struct UserListManager {
    
    var delegate: UserDataManagerDelegate?
    let userDatabaseURL = "https://api.github.com/"
    let userDatabasePathURL = "search/users"
    let query = "?q="
    let parameters = "+in:login+type%3Auser&type=Users"
    let pageParamter = "&page="
    let perPageParameter = "&per_page="
    
    func fetchUsers(username: String, page: Int? = nil, perPage: Int = 30){
        var urlString = userDatabaseURL
        urlString.append(contentsOf: userDatabasePathURL)
        urlString.append(contentsOf: query)
        urlString.append(contentsOf: username)
        urlString.append(contentsOf: parameters)
        if let page = page {
            urlString.append(pageParamter)
            urlString.append(String(page))
                urlString.append(perPageParameter)
                urlString.append(String(perPage))
        }
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in

                if let response = response as? HTTPURLResponse {
                    print(response.statusCode)
                }
                if error != nil {
                    self.delegate?.didFailWithErrors(error: error!)
                    return
                }
                if let safeData = data {
                    if let userData = self.parseJSONtoUserModel(safeData){
                        self.delegate?.didUpdateUsers(self, users: userData)
                    }
                }
            }
            task.resume()
        } else {
            fatalError("URL failed to start task")
        }
    }
    
    func parseJSONtoUserModel(_ data: Data) -> [UserModel]? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let decodedData = try decoder.decode(UserListData.self, from: data)
            let totalCount = decodedData.totalCount
            print("Total count of object in data retrieved is: \(totalCount)")
            print("items retrieved in this call: \(decodedData.items.count)")
            let incompleteResults = decodedData.incompleteResults
            print("Retrived data is incomplete: \(incompleteResults)")
            
            let items = decodedData.items
            var userModels: [UserModel] = []
            for i in 0...items.count-1 {
                let user = items[i]
                userModels.append(UserModel(userName: user.login, avatarUrl: user.avatarUrl))
            }
            return userModels
        } catch {
            delegate?.didFailWithErrors(error: error)
            return nil
        }
    }
}

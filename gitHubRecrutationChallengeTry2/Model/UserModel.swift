//
//  UserModel.swift
//  gitHubRecrutationChallengeTry2
//
//  Created by Tomasz Kubiak on 7/21/22.
//

import Foundation

struct UserModel: Equatable {
    
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.userName == rhs.userName
    }
    
    let userName: String
    let avatarUrl: String
    let imageModel: ImageModel
    let id = UUID()
    
    init(userName: String, avatarUrl: String) {
        self.userName = userName
        self.avatarUrl = avatarUrl
        self.imageModel = ImageModel(url: avatarUrl)
    }
    init(realmUserModel: RealmUserModel) {
        self.userName = realmUserModel.userName
        self.avatarUrl = realmUserModel.avatarUrl
        self.imageModel = ImageModel(url: realmUserModel.avatarUrl)
    }
}

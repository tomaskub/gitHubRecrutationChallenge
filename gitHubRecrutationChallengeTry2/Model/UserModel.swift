//
//  UserModel.swift
//  gitHubRecrutationChallengeTry2
//
//  Created by Tomasz Kubiak on 7/21/22.
//

import Foundation

struct UserModel {
    let userName: String
    let avatarUrl: String
    let imageModel: ImageModel
    let id = UUID()
}

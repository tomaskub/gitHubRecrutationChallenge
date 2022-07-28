//
//  UserListData.swift
//  gitHubRecrutationChallengeTry2
//
//  Created by Tomasz Kubiak on 7/21/22.
//

import Foundation
struct UserListData: Codable {
    
    let totalCount: Int
    let incompleteResults: Bool
    let items: [UserItem]
    
}
struct MainRequired: Codable {
   
}
struct UserItem: Codable {
    let login: String
    let id: Int
    let nodeId: String
    let avatarUrl: String
    let gravatarId: String
    let url: String
    let htmlUrl: String
    let followersUrl: String
    let followingUrl: String
    let gistsUrl: String
    let starredUrl: String
    let subscriptionsUrl: String
    let organizationsUrl: String
    let reposUrl: String
    let eventsUrl: String
    let receivedEventsUrl: String
    let type: String
    let siteAdmin: Bool
    let score: Double
    let name: String?
    let company: String?
    let blog: String?
    let location: String?
    let email: String?
    let hireable: String?
    let bio: String?
    let twitter_username: String?
    let public_repos: String?
    let public_gists: String?
    let followers: Int?
    let following: Int?
    let created_at: String?
    let updated_at: String?
}

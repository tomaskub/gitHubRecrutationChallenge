//
//  RealmUserModel.swift
//  gitHubRecrutationChallengeTry2
//
//  Created by Tomasz Kubiak on 7/28/22.
//

import Foundation
import RealmSwift


class RealmUserModel: Object {
    @Persisted var userName: String
    @Persisted var avatarUrl: String
}

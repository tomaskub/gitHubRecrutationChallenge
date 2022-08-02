//
//  ImageModel.swift
//  gitHubRecrutationChallengeTry2
//
//  Created by Tomasz Kubiak on 7/24/22.
//

import Foundation

struct ImageModel {
    
    public private(set) var url: URL?
    
    init(url: String?) {
        if let urlString = url {
            self.url = URL(string: urlString)
        }
    }
}

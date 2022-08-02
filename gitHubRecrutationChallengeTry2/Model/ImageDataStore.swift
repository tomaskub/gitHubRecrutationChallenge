//
//  ImageDataStore.swift
//  gitHubRecrutationChallengeTry2
//
//  Created by Tomasz Kubiak on 8/2/22.
//

import Foundation

class ImageDataStore {
    
    private var images: [ImageModel]?
    
    public var numberOfImage: Int {
        if let images = images {
            return images.count
        } else {
        return 0
        }
    }
    
    init (){
        self.images = nil
    }
    
    init (userModels: [UserModel]){
        var _images = [ImageModel]()
        for user in userModels {
            _images.append(user.imageModel)
        }
            self.images = _images
            
    }
    
    public func appendUsers(userModels: [UserModel]) {
        
            for userModel in userModels {
                images?.append(userModel.imageModel)
        
        }
    }
    
    public func removeUser(userModels: [UserModel]){
        for userModel in userModels {
            images?.removeAll(where: {$0.url == URL(string: userModel.avatarUrl)})
        }
        
    }

    public func loadImage(at index: Int) -> DataLoadOperation? {
        if let images = images {
            if (0..<images.count).contains(index) {
                return DataLoadOperation(images[index])
            }
        }
        return .none
    }
}

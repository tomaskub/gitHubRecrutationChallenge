//
//  DataLoadOperation.swift
//  gitHubRecrutationChallengeTry2
//
//  Created by Tomasz Kubiak on 7/24/22.
//

import Foundation
import UIKit



class DataLoadOperation: Operation {
    
    var image: UIImage?
    var loadingCompleteHandler: ((UIImage?) -> ())?

    private let imageModel: ImageModel
    
    init(_ imageModel: ImageModel) {
        self.imageModel = imageModel
    }
    
    override func main() {
        if isCancelled { return }
        guard let url = imageModel.url else { return }
        downloadImageFrom(url) { (image) in
            DispatchQueue.main.async {
                [weak self] in
                
                guard let self = self else { return }
//                if self.isCancelled { return }
                self.image = image
                self.loadingCompleteHandler?(self.image)
            }
        }
    }
    
}

class ImageDataStore {
//    this should come from users.avatarUrl
    private var images: [ImageModel]?
    
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
    
    public var numberOfImage: Int {
        if let images = images {
            return images.count
        } else {
        return 0
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
// check escaping conotation, what is mimeType and URLSession
private func downloadImageFrom( _ url: URL, completeHandler: @escaping (UIImage?) -> ()) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let e = error {
            print(e) }
        guard
           let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
           let mimeType = httpURLResponse.mimeType, mimeType.hasPrefix("image"),
           let data = data, error == nil,
           let _image = UIImage(data: data)
            
        else {
        print("download image from func fialed ")
        return
        
    }
        completeHandler(_image)
    }.resume()
}

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
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.image = image
                self.loadingCompleteHandler?(self.image)
            }
        }
    }
    
}

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

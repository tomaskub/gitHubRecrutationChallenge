//
//  UserDetailViewController.swift
//  gitHubRecrutationChallengeTry2
//
//  Created by Tomasz Kubiak on 7/28/22.
//

import UIKit
import RealmSwift

protocol UserDetailViewControllerDelegate {
    func userAddedToFavorites()
    func userRemovedFromFavorites(userModel: UserModel)
}

class UserDetailViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var saveAsFavButton: UIButton!
    
    
    let localRealm = try! Realm()
    
    private var userModel: UserModel?
    var delegate: UserDetailViewControllerDelegate?
    var image: UIImage?
    private var isUserFavorite: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userModel = userModel {
            userNameLabel.text = userModel.userName
            
            let results = localRealm.objects(RealmUserModel.self).where({
                $0.userName == userModel.userName
            })
            
            configureViewFor(_isUserFavorite: !results.isEmpty)
        }
        if let _image = image {
            userAvatarImage.image = _image
        }
        
        // Do any additional setup after loading the view.
    }
    func configureViewFor(_isUserFavorite: Bool){
        if _isUserFavorite {
            isUserFavorite = true
            saveAsFavButton.setTitle("Remove from favorites", for: .normal)
            saveAsFavButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            isUserFavorite = false
            saveAsFavButton.setTitle("Save user to favorites", for: .normal)
            saveAsFavButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
    }
    func setForFavoriteUser() {
        
    }
    
    func assignUserModel(user: UserModel) {
        self.userModel = user
    }
    @IBAction func saveToFavoriteTouched(_ sender: Any) {
        if let userModel = userModel, let _isUserFavorite = isUserFavorite {
            if !_isUserFavorite {
                configureViewFor(_isUserFavorite: true)
                try! localRealm.write({
                    let user = RealmUserModel(value: ["userName": userModel.userName, "avatarUrl": userModel.avatarUrl])
                    localRealm.add(user)
                })
                delegate?.userAddedToFavorites()
            } else {
                configureViewFor(_isUserFavorite: false)
                try! localRealm.write({
                    let user = localRealm.objects(RealmUserModel.self).where({
                        $0.userName == userModel.userName})
                    localRealm.delete(user)
                })
                delegate?.userRemovedFromFavorites(userModel: userModel)
            }
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

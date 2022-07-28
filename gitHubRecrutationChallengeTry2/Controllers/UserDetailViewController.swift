//
//  UserDetailViewController.swift
//  gitHubRecrutationChallengeTry2
//
//  Created by Tomasz Kubiak on 7/28/22.
//

import UIKit
import RealmSwift

class UserDetailViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var saveAsFavButton: UIButton!
    
    
    let localRealm = try! Realm()
    
    private var userModel: UserModel?
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userModel = userModel {
            userNameLabel.text = userModel.userName
        }
        if let _image = image {
            userAvatarImage.image = _image
        }
        // Do any additional setup after loading the view.
    }
    
    func assignUserModel(user: UserModel) {
        self.userModel = user
    }
    @IBAction func saveToFavoriteTouched(_ sender: Any) {
        if let userModel = userModel {
            let user = RealmUserModel(value: ["userName": userModel.userName, "avatarUrl": userModel.avatarUrl])
            try! localRealm.write({
                localRealm.add(user)
            })
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

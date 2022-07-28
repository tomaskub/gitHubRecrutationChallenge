//
//  UserCell.swift
//  gitHubRecrutationChallengeTry2
//
//  Created by Tomasz Kubiak on 7/23/22.
//

import UIKit

class UserCell: UITableViewCell {
    
    public static let identifier = "UserCell"
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    private var userModel: UserModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    func configureCell(user: UserModel){
            userModel = user
            userNameLabel.text = user.userName
    }
    /// Configure cell image
    /// - Parameter image: UIimage to pass to the cell
    func configureCell(_ image: UIImage?) {
//        why unowned self?
        DispatchQueue.main.async { [unowned self] in
            self.displayImage(image)
        }
    }
        
    /// Configure cell without username, image, or loading indicator - text to display is "Search of an user or check favorites"
    func configureCell() {
        userNameLabel.text = "Search for an user or check favorites!"
        loadingIndicator.stopAnimating()
        userAvatarImage.image = .none
    }

    
    private func displayImage(_ image: UIImage?) {
        if let _image = image {
            userAvatarImage.image = _image
            loadingIndicator.stopAnimating()
        } else {
//            where to put loading indicator?
            loadingIndicator.startAnimating()
            userAvatarImage.image = .none
        }
    }
    public func getUserModel() -> UserModel? {
        return userModel
    }
}

//
//  UserCell.swift
//  gitHubRecrutationChallengeTry2
//
//  Created by Tomasz Kubiak on 7/23/22.
//

import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userAvatarImage: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tipLabel: UILabel!
    
    private var userModel: UserModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userAvatarImage.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    /// Configure cell with userModel and to display user model data
    /// - Parameter user: UserModel to be displayed by this cell
    public func configureCell(user: UserModel){
        userModel = user
        userNameLabel.isHidden = false
        userNameLabel.text = user.userName
        tipLabel.isHidden = true
    }
    /// Configure cell image
    /// - Parameter image: UIimage to pass to the cell
    public func configureCell(_ image: UIImage?) {
        DispatchQueue.main.async { [unowned self] in
            self.displayImage(image)
        }
    }
        
    /// Configure cell without username, image, or loading indicator - text to display is "Search of an user or check favorites"
    func configureCell() {
        tipLabel.text = "Search for an user or check favorites!"
        userNameLabel.isHidden = true
        tipLabel.isHidden = false
        loadingIndicator.stopAnimating()
        userAvatarImage.image = .none
    }

    
    ///  Display image in cell and handle loading interaction presence
    /// - Parameter image: UIImage to display in a cell
    private func displayImage(_ image: UIImage?) {
        if let _image = image {
            userAvatarImage.image = _image
            loadingIndicator.stopAnimating()
        } else {
            loadingIndicator.startAnimating()
            userAvatarImage.image = .none
        }
    }
    
    /// - Returns: userModel assigned to the cell
    public func getUserModel() -> UserModel? {
        return userModel
    }
    
    /// - Returns: user image assigned to the cell
    public func getUserImage() -> UIImage? {
        return userAvatarImage.image
    }
}

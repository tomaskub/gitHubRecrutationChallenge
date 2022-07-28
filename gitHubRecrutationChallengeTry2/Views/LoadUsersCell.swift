//
//  LoadUsersCell.swift
//  gitHubRecrutationChallengeTry2
//
//  Created by Tomasz Kubiak on 7/24/22.
//

import UIKit

protocol LoadUsersCellDelegate {
    func loadMoreUsers()
}


class LoadUsersCell: UITableViewCell {
    
    var delegate: LoadUsersCellDelegate?
    
    @IBOutlet weak var loadMoreUsersButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicator.stopAnimating()
        loadMoreUsersButton.isHidden = false
    }
    
    @IBAction func loadMoreUsersButtonTapped(_ sender: Any) {
        activityIndicator.startAnimating()
        loadMoreUsersButton.isHidden = true
        delegate?.loadMoreUsers()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

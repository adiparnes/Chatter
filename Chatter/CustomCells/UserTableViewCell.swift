//
//  UserTableViewCell.swift
//  Chatter
//
//  Created by Avihai Shabtai on 22/02/2020.
//  Copyright © 2020 Niv-Ackerman. All rights reserved.
//

import UIKit

protocol UserTableViewCellDelegate {
    func didTapAvatarImage(indexPath: IndexPath)
}

class UserTableViewCell: UITableViewCell {

 
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
   
    var indexPath: IndexPath!
    var delegate: UserTableViewCellDelegate?
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tapGestureRecognizer.addTarget(self, action: #selector(self.avatarTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    
    func genrateCellWith(fUser:FUser, indexPath: IndexPath)
    {
        self.indexPath = indexPath
        self.fullNameLabel.text = fUser.fullname
        
        if fUser.avatar != "" {
            imageFromData(pictureData: fUser.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
    }
    
    @objc func avatarTap()
    {
        delegate!.didTapAvatarImage(indexPath: indexPath)
    }
    
}

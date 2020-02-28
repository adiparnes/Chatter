//
//  RecentChatTableViewCell.swift
//  Chatter
//
//  Created by Avihai Shabtai on 23/02/2020.
//  Copyright © 2020 Niv-Ackerman. All rights reserved.
//

import UIKit


protocol RecentChatTableViewCellDelegate {
    func didTapAvatarImage(indexPath: IndexPath)
}



class RecentChatTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLable: UILabel!
    
    @IBOutlet weak var lastMeassegeLable: UILabel!
    
    @IBOutlet weak var meassageCounterBackgroundView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageCounter: UILabel!
  
    
    var delegate: RecentChatTableViewCellDelegate?
    
    var indexPath: IndexPath!
    
    let tapGesture = UITapGestureRecognizer()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        meassageCounterBackgroundView.layer.cornerRadius = meassageCounterBackgroundView.frame.width / 2
        
        tapGesture.addTarget(self, action: #selector(self.avatarTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    //MARK: Generate cell
    
    func genrateCell(recentChat: NSDictionary, indexPath: IndexPath) {
        
        self.indexPath = indexPath
        
        self.nameLable.text = recentChat[kWITHUSERFULLNAME] as? String
        
        self.lastMeassegeLable.text = recentChat[kLASTMESSAGE] as? String
        
        self.messageCounter.text = recentChat[kCOUNTER] as? String
        
        if let avatarString = recentChat[kAVATAR] {
            imageFromData(pictureData: avatarString as! String) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
        
        if recentChat[kCOUNTER] as! Int != 0 {
            self.messageCounter.text = "\(recentChat[kCOUNTER] as! Int)"
            self.meassageCounterBackgroundView.isHidden = false
            self.messageCounter.isHidden = false
            
        }else{
        
        self.meassageCounterBackgroundView.isHidden = true
        self.messageCounter.isHidden = true
        }
        
        var date: Date!
        
        if let created = recentChat[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
                
            }else {
                date = dateFormatter().date(from: created as! String)!
            }
        }else {
            date = Date()
        }
        
        self.dateLabel.text = timeElapsed(date: date)
        
    }

    
    
    @objc func avatarTap()
    {
        print("avatar tap")
        delegate?.didTapAvatarImage(indexPath: indexPath)
    }
    
}

//
//  PicturesCollectionViewCell.swift
//  Chatter
//
//  Created by Avihai Shabtai on 29/02/2020.
//  Copyright © 2020 Niv-Ackerman. All rights reserved.
//

import UIKit

class PicturesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(image: UIImage) {
        self.isUserInteractionEnabled = true
        self.imageView.image = image
    }
}

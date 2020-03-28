//
//  BackgroundCollectionViewCell.swift
//  Chatter
//
//  Created by Avihai Shabtai on 07/03/2020.
//  Copyright © 2020 Niv-Ackerman. All rights reserved.
//

import UIKit

class BackgroundCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(image: UIImage) {
        self.imageView.image = image
    }
    
    
}

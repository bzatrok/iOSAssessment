//
//  BBGridCollectionViewCell.swift
//  BestBuy
//
//  Created by Ben Zatrok on 28/02/17.
//  Copyright © 2017 AmberGlass. All rights reserved.
//

import UIKit

class BBGridCollectionViewCell: UICollectionViewCell
{
    //MARK: Variables
    
    //MARK: IBOutlets
    
    @IBOutlet weak var backgroundImageView  : UIImageView!
    @IBOutlet weak var priceLabel           : UILabel!
    
    //MARK: Life-cycle
    
    func setupCell(withImageURL imageURL: String, price: Double)
    {
        backgroundImageView.kf.setImage(with: URL(string: imageURL))
        priceLabel.text = "$\(price)"
    }
    
}

//
//  ItemCell.swift
//  FoodZilla
//
//  Created by Denis Rakitin on 2019-09-10.
//  Copyright © 2019 Denis Rakitin. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodPrice: UILabel!
    @IBOutlet weak var foodName: UILabel!
    
    func configureCell (forItem item: Item) {
        foodImage.image = item.image
        foodPrice.text = item.name
        foodName.text = String(describing: item.price)
    }
}

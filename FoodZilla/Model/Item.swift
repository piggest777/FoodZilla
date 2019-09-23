//
//  Item.swift
//  FoodZilla
//
//  Created by Denis Rakitin on 2019-09-10.
//  Copyright © 2019 Denis Rakitin. All rights reserved.
//

import UIKit
class Item {
    public private(set) var image: UIImage
    public private(set) var name: String
    public private(set) var price: Double
    
    init(image: UIImage, name: String, price: Double) {
        self.image = image
        self.name = name
        self.price = price
    }
}

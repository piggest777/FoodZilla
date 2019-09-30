//
//  DateExt.swift
//  FoodZilla
//
//  Created by Denis Rakitin on 2019-09-27.
//  Copyright © 2019 Denis Rakitin. All rights reserved.
//

import Foundation

extension Date {
    func isLessThan(_ date: Date) -> Bool {
        if self.timeIntervalSince(date) < date.timeIntervalSinceNow {
            return true
        } else {
            return false
        }
    }
}

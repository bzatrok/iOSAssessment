//
//  BBDoubleExtensions.swift
//  BestBuy
//
//  Created by Ben Zatrok on 27/02/17.
//  Copyright © 2017 AmberGlass. All rights reserved.
//

import UIKit

extension Double
{
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double
    {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

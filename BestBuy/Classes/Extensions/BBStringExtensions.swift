//
//  BBStringExtensions.swift
//  BestBuy
//
//  Created by Ben Zatrok on 01/03/17.
//  Copyright © 2017 AmberGlass. All rights reserved.
//

import Foundation

extension String
{
    func removeSpecialChars() -> String
    {
        struct Constants
        {
            static let validChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:;/'!_".characters)
        }
        return String(characters.filter { Constants.validChars.contains($0) })
    }
}

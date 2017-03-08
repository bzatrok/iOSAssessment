//
//  BBCategory.swift
//  BestBuy
//
//  Created by Ben Zatrok on 27/02/17.
//  Copyright © 2017 AmberGlass. All rights reserved.
//

import Foundation

class BBCategory : BBObject
{
    let id : String?
    
    init(_name: String,
         _id: String?)
    {
        id      = _id
        
        super.init(object_name: _name)
    }
}

//
//  BBUIViewExtensions.swift
//  BestBuy
//
//  Created by Ben Zatrok on 26/02/17.
//  Copyright © 2017 AmberGlass. All rights reserved.
//

import UIKit

extension UIView
{
    func findFirstResponder() -> UIResponder?
    {
        if isFirstResponder
        {
            return self
        }
        
        for view in subviews
        {
            if let responder = view.findFirstResponder()
            {
                return responder
            }
        }
        
        return nil
    }
    
    func animateAlpha(toValue value: Double)
    {
        let floatValue = CGFloat(value)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            
            self?.alpha = floatValue
        }
    }
}

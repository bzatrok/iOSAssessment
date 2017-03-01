//
//  BBUITableViewExtensions.swift
//  BestBuy
//
//  Created by Ben Zatrok on 27/02/17.
//  Copyright © 2017 AmberGlass. All rights reserved.
//

import UIKit

extension UITableView
{
    /**
     Reloads tableview
     */
    func reloadAnimated()
    {
        DispatchQueue.main.sync {
            
            beginUpdates()
            let sections = NSIndexSet(indexesIn: NSMakeRange(0, numberOfSections))
            reloadSections(sections as IndexSet, with: .fade)
            endUpdates()
        }
    }
    
    /**
     Scrolls tableview to top
     */
    func scrollToTop()
    {
        guard numberOfRows(inSection: 0) > 0 else
        {
            return
        }
        
        DispatchQueue.main.async {
            
            let topIndexPath = IndexPath(row: 0, section: 0)
            
            self.scrollToRow(at: topIndexPath, at: .top, animated: true)
        }
    }
}

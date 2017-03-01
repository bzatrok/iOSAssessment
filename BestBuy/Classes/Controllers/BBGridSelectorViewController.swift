//
//  BBGridSelectorViewController.swift
//  BestBuy
//
//  Created by Ben Zatrok on 28/02/17.
//  Copyright © 2017 AmberGlass. All rights reserved.
//

import UIKit

class BBGridSelectorViewController: UIViewController
{

    //MARK: Variables
    
    var itemsList                   : [BBObject] = []
    var SKUList                     : [Int]?
    
    var selectedItem                : BBObject?
    
    let gridCellID                  = "gridCellID"
    let emptyCellID                 = "emptyCellID"
    
    let accessoryProductDetailSegue = "accessoryProductDetailSegue"
    
    //MARK: IBOutlets
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    //MARK: IBActions
    
    //MARK: Life-Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupDelegation()
        setupView()
    }
    
    //MARK: Functions
    
    /**
     Sets up required delegates
     */
    func setupDelegation()
    {
        collectionView.delegate      = self
        collectionView.dataSource    = self
    }
    
    /**
     Sets up the view and fetches required data
     */
    func setupView()
    {
        guard let SKUList = SKUList, SKUList.count > 0 else
        {
            return
        }
        
        BBRequestManager.shared.queryProducts(withSKUs: SKUList) { [weak self] success, responseProductsList in
            
            guard let strongSelf = self, let responseProductsList = responseProductsList, success else
            {
                return
            }
            
            strongSelf.itemsList = responseProductsList
            
            DispatchQueue.main.async {
                strongSelf.collectionView.reloadData()
            }
        }
    }
    
    //MARK: Segue handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let selectedProduct = selectedItem as? BBProduct,
            let destination = segue.destination as? BBProductDetailViewController,
            segue.identifier == accessoryProductDetailSegue else
        {
            return
        }
        
        destination.selectedProduct = selectedProduct
    }
}

extension BBGridSelectorViewController: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        selectedItem = itemsList[indexPath.row]
        performSegue(withIdentifier: accessoryProductDetailSegue, sender: self)
    }
}

extension BBGridSelectorViewController: UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return itemsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridCellID, for: indexPath) as? BBGridCollectionViewCell,
            let product = itemsList[indexPath.row] as? BBProduct else
        {
            return collectionView.dequeueReusableCell(withReuseIdentifier: emptyCellID, for: indexPath)
        }
        
        cell.backgroundImageView.contentMode = .scaleAspectFit
        
        if let image_URL = product.image_URL
        {
            DispatchQueue.main.async {
                cell.backgroundImageView.kf.setImage(with: URL(string: image_URL), placeholder: nil, options: nil, progressBlock: nil) { Image, error, cacheType, url in
                    
                    cell.setNeedsLayout()
                }
            }
        }
        
        if let sale_price = product.sale_price,
            let regular_price = product.regular_price
        {
            let salePriceString = NSMutableAttributedString(string: "$\(sale_price) ")
            
            if sale_price != regular_price
            {
                let strikeThroughPriceString: NSMutableAttributedString = NSMutableAttributedString(string: "$\(regular_price)")
                
                strikeThroughPriceString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, strikeThroughPriceString.length))
                
                salePriceString.append(strikeThroughPriceString)
            }
            
            cell.priceLabel.attributedText = salePriceString
        }
        
        return cell
    }
}

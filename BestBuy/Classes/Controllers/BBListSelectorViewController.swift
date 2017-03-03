//
//  BBListSelectorViewController.swift
//  BestBuy
//
//  Created by Ben Zatrok on 27/02/17.
//  Copyright © 2017 AmberGlass. All rights reserved.
//

import UIKit

enum BBListSelectorState: Int
{
    case categories
    case relatedProducts
    
    static var count: Int
    {
        var current = 0
        while let _ = self.init(rawValue: current) { current += 1 }
        return current
    }
}

class BBListSelectorViewController: UIViewController
{
    //MARK: Variables
    
    var itemsList                   : [BBObject] = []
    var SKUList                     : [Int]?
    
    var currentState                : BBListSelectorState?
    
    var currentPageNumber           = 1
    var isHTTPRequestInProgress     = false
    
    var selectedItem                : BBObject?
    
    let itemCellID                  = "itemCellID"
    let emptyCellID                 = "emptyCellID"
    let itemCellHeight              : CGFloat = 60
    let emptyCellHeight             : CGFloat = 0
    
    let relatedProductDetailSegue   = "relatedProductDetailSegue"
    
    //MARK: IBOutlets
    
    @IBOutlet weak var tableView    : UITableView!
    
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
        tableView.delegate      = self
        tableView.dataSource    = self
    }
    
    /**
     Sets up the view and fetches required data
     */
    func setupView()
    {
        edgesForExtendedLayout  = []
        currentState            = currentState != nil ? currentState : .relatedProducts
        
        guard let currentState = currentState, let guardedState = BBListSelectorState(rawValue: currentState.rawValue) else
        {
            return
        }
        
        switch guardedState
        {
            case .relatedProducts:
                
                guard let SKUList = SKUList, SKUList.count > 0 else
                {
                    return
                }
            
                BBRequestManager.shared.queryProducts(withSKUs: SKUList) { [weak self] success, productsList in
                    
                    guard let strongSelf = self, let productsList = productsList, success else
                    {
                        return
                    }
                    strongSelf.itemsList = productsList
                    
                    DispatchQueue.main.async {
                        strongSelf.tableView.reloadAnimated()
                    }
                }
                
            case .categories:
                
                BBRequestManager.shared.queryCategories(currentPageNumber: currentPageNumber) { [weak self] success, responseCategories in
                    
                    guard let strongSelf = self, let responseCategories = responseCategories, success else
                    {
                        return
                    }
                    strongSelf.itemsList = responseCategories
                    strongSelf.currentPageNumber += 1
                    
                    DispatchQueue.main.async {
                        strongSelf.tableView.reloadAnimated()
                    }
                }
                
                let clearFilterButton   = UIBarButtonItem(title: "Clear Filter", style: .plain, target: self, action: #selector(clearFilterButtonClicked))
                
                navigationItem.setRightBarButtonItems([clearFilterButton], animated: true)
        }
    }
    

    func clearFilterButtonClicked(sender: UIBarButtonItem)
    {
        BBFilterManager.shared.selectedTopLevelCategoryID   = nil
        BBFilterManager.shared.selectedTopLevelCategoryName = nil
        
        guard let navigationController = navigationController else
        {
            return
        }
        
        navigationController.popViewController(animated: true)
    }
    
    //MARK: Segue handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let currentState = currentState,
            let guardedState = BBListSelectorState(rawValue: currentState.rawValue),
            guardedState == .relatedProducts,
            let selectedProduct = selectedItem as? BBProduct,
            let destination = segue.destination as? BBProductDetailViewController,
            segue.identifier == relatedProductDetailSegue else
        {
            return
        }
        
        destination.selectedProduct = selectedProduct
    }
}

//MARK: UIScrollViewDelegate

extension BBListSelectorViewController: UIScrollViewDelegate
{
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        guard let currentState = currentState,
            let guardedState = BBListSelectorState(rawValue: currentState.rawValue) else
        {
            return
        }
        
        switch guardedState
        {
            case .categories:
            
                if ((tableView.contentOffset.y + tableView.frame.size.height) >= tableView.contentSize.height - itemCellHeight)
                {
                    isHTTPRequestInProgress = true
                    
                    BBRequestManager.shared.queryCategories(currentPageNumber: self.currentPageNumber) { [weak self] success, responseCategoryList in
                        
                        self?.isHTTPRequestInProgress = false
                        
                        guard let strongSelf = self, let responseCategoryList = responseCategoryList, success else
                        {
                            return
                        }
                        
                        DispatchQueue.main.async {
                            
                            strongSelf.currentPageNumber += 1
                            
                            strongSelf.tableView.beginUpdates()
                            
                            let insertIndex = strongSelf.itemsList.count - 1
                            var indexPaths  : [IndexPath] = []
                            
                            for index in insertIndex...insertIndex + responseCategoryList.count - 1
                            {
                                indexPaths.append(IndexPath(row: index, section: 0))
                            }
                            
                            strongSelf.itemsList = strongSelf.itemsList + responseCategoryList
                            
                            strongSelf.tableView.insertRows(at: indexPaths, with: .automatic)
                            strongSelf.tableView.endUpdates()
                            
                            strongSelf.tableView.setNeedsLayout()
                        }
                    }
                }
                
            default:
                break
        }
    }
}

//MARK: UITableViewDelegate

extension BBListSelectorViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard let currentState = currentState, let guardedState = BBListSelectorState(rawValue: currentState.rawValue) else
        {
            return
        }
        
        switch guardedState
        {
            case .relatedProducts:
                
                guard let selectedRelatedProduct = itemsList[indexPath.row] as? BBProduct else
                {
                    return
                }
                
                selectedItem = selectedRelatedProduct
            
                performSegue(withIdentifier: relatedProductDetailSegue, sender: self)
                
            case .categories:
                
                guard let selectedCategory = itemsList[indexPath.row] as? BBCategory else
                {
                    return
                }
                
                BBFilterManager.shared.selectedTopLevelCategoryID   = selectedCategory.id
                BBFilterManager.shared.selectedTopLevelCategoryName = selectedCategory.name
                
                guard let navigationController = navigationController else
                {
                    return
                }
                
                navigationController.popViewController(animated: true)
        }
    }
}

//MARK: UITableViewDataSource

extension BBListSelectorViewController: UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return itemsList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return itemCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell                = tableView.dequeueReusableCell(withIdentifier: itemCellID, for: indexPath) as? UITableViewCell
       
        if let product = itemsList[indexPath.row] as? BBProduct,
            let sale_price = product.sale_price
        {
            cell?.textLabel?.text       = product.name
            cell?.detailTextLabel?.text = "$\(sale_price.roundTo(places: 2))"
            
            if let thumbnail_image_URL = product.thumbnail_image_URL
            {
                cell?.imageView?.kf.setImage(with: URL(string: thumbnail_image_URL), placeholder: nil, options: nil, progressBlock: nil) { Image, error, cacheType, url in

                    DispatchQueue.main.async {
                        cell?.setNeedsLayout()
                    }
                }
            }
        }
        else
        {
            let item = itemsList[indexPath.row]
            
            cell?.textLabel?.text = item.name
        }
        
        return cell!
    }
}

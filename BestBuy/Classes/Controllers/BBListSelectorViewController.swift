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
    
    var selectedItem                : BBObject?
    
    let itemCellID                  = "itemCellID"
    let emptyCellID                 = "emptyCellID"
    let itemCellHeight              : CGFloat = 44
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
                    strongSelf.tableView.reloadAnimated()
                }
                
            case .categories:
                
                BBRequestManager.shared.queryCategories { [weak self] success, responseCategories in
                    
                    guard let strongSelf = self, let responseCategories = responseCategories, success else
                    {
                        return
                    }
                    strongSelf.itemsList = responseCategories
                    strongSelf.tableView.reloadAnimated()
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
        let item                = itemsList[indexPath.row]
        
        cell?.textLabel?.text   = item.name
        
        return cell!
    }
}
//
//  BBSearchViewController.swift
//  BestBuy
//
//  Created by Ben Zatrok on 23/02/17.
//  Copyright © 2017 AmberGlass. All rights reserved.
//

import UIKit
import Kingfisher

class BBSearchViewController: UIViewController
{
    //MARK: Variables
    
    var productsList                : [BBProduct] = []
    var selectedProduct             : BBProduct?
    
    var currentPageNumber           = 1
    var isHTTPRequestInProgress     = false
    
    var currentSearchButtonState    : BBSearchButtonState = .search
    
    let productCellID               = "productCell"
    let emptyCellID                 = "emptyCell"
    let productCellHeight           : CGFloat = 60
    let emptyCellHeight             : CGFloat = 0
    
    let productDetailSeque          = "productDetailSeque"
    let categorySeletorSegue        = "categorySeletorSegue"
    
    //MARK: IBOutlets
    
    @IBOutlet weak var searchBar    : UISearchBar!
    @IBOutlet weak var tableView    : UITableView!
    @IBOutlet weak var searchButton : UIButton!
    
    //MARK: Enums
    
    enum ProductTableSection: Int
    {
        case list
        
        static var count: Int
        {
            var current = 0
            while let _ = self.init(rawValue: current) { current += 1 }
            return current
        }
    }
    
    enum BBSearchButtonState: Int
    {
        case search
        case showAllFromCategory
        case searching
        case noResults
        case loadingNextPage
        
        static var count: Int
        {
            var current = 0
            while let _ = self.init(rawValue: current) { current += 1 }
            return current
        }
    }
    
    //MARK: IBActions
    
    @IBAction func searchButtonClicked(_ sender: Any)
    {
        if let searchBarText = searchBar.text,
            searchBarText.characters.count > 0,
            BBFilterManager.shared.selectedTopLevelCategoryID == nil
        {
            fetchProducts(withSearchText: searchBarText, limitedToCategoryWithID: nil)
        }
        else if let searchBarText = searchBar.text,
            searchBarText.characters.count > 0,
            let selectedCategoryID = BBFilterManager.shared.selectedTopLevelCategoryID
        {
            fetchProducts(withSearchText: searchBarText, limitedToCategoryWithID: selectedCategoryID)
        }
        else if let selectedCategoryID = BBFilterManager.shared.selectedTopLevelCategoryID
        {
            fetchProducts(withSearchText: nil, limitedToCategoryWithID: selectedCategoryID)
        }
        else
        {
            searchBar.becomeFirstResponder()
            return
        }
        
        setSearchButtonState(.searching)
        
        tableView.scrollToTop()
        
        if searchBar.isFirstResponder
        {
            searchBar.resignFirstResponder()
        }
    }
    
    //MARK: Life-Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupDelegation()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        setupView()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    //MARK: Functions
    
    /**
     Sets up required delegates
     */
    func setupDelegation()
    {
        searchBar.delegate      = self
        tableView.delegate      = self
        tableView.dataSource    = self
        
        //Add category filter button
        
        let categoriesButton = UIBarButtonItem(title: "Categories", style: .plain, target: self, action: #selector(categoriesButtonClicked))
        navigationItem.setRightBarButtonItems([categoriesButton], animated: true)
    }
    
    func setupView()
    {
        setSearchButtonState(.search)
    
        if let _ = BBFilterManager.shared.selectedTopLevelCategoryID,
            let searchBar = searchBar,
            let searchBarText = searchBar.text,
            searchBarText.characters.count == 0
        {
            setSearchButtonState(.showAllFromCategory)
        }
    
        //Set prompt text on searchbar (changes if filtering is enabled)
        let selectedCategory    = BBFilterManager.shared.selectedTopLevelCategoryName != nil ? "the '\(BBFilterManager.shared.selectedTopLevelCategoryName!)' category" : "BestBuy's products"
        
        searchBar.prompt        = "Search among \(selectedCategory)"
        searchBar.barTintColor  = BBColors.blue
        
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView,
            let searchBarPromptLabel = searchBar.value(forKey: "promptLabel") as? UILabel else
        {
            return
        }
        
        statusBar.backgroundColor       = BBColors.blue
        searchBarPromptLabel.textColor  = UIColor.white
    }
    
    func setSearchButtonState(_ toState: BBSearchButtonState)
    {
        currentSearchButtonState = toState
        
        DispatchQueue.main.async {
        
            UIView.animate(withDuration: 0.3) {
                
                switch toState
                {
                    case .searching:
                    
                        self.searchButton.setTitle("Searching...", for: .normal)
                        self.searchButton.setBackgroundImage(UIImage(color: BBColors.red), for: .normal)
                        
                    case .search:
                        
                        self.searchButton.setTitle("Search", for: .normal)
                        self.searchButton.setBackgroundImage(UIImage(color: BBColors.blue), for: .normal)
                    
                    case .showAllFromCategory:
                        
                        self.searchButton.setTitle("Show all from Category", for: .normal)
                        self.searchButton.setBackgroundImage(UIImage(color: BBColors.blue), for: .normal)
                    
                    case .noResults:
                    
                        self.searchButton.setTitle("No Results Found", for: .normal)
                        self.searchButton.setBackgroundImage(UIImage(color: BBColors.grey), for: .normal)
                    
                    case .loadingNextPage:
                        self.searchButton.setTitle("Loading next page...", for: .normal)
                        self.searchButton.setBackgroundImage(UIImage(color: BBColors.red), for: .normal)
                }
            }
        }
    }
    
    //MARK: Barbuttons
    
    func categoriesButtonClicked(sender: UIBarButtonItem)
    {
        performSegue(withIdentifier: categorySeletorSegue, sender: self)
    }
    
    //MARK: Segue handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let selectedProduct = selectedProduct, let destination = segue.destination as? BBProductDetailViewController, segue.identifier == productDetailSeque
        {
            destination.selectedProduct = selectedProduct
        }
        else if let destination = segue.destination as? BBListSelectorViewController
        {
            destination.currentState    = .categories
        }
    }
    
    //MARK: Fetch products
    
    func fetchProducts(withSearchText searchText: String?, limitedToCategoryWithID: String?)
    {
        if searchText == nil && limitedToCategoryWithID == nil
        {
            setSearchButtonState(.search)
            searchButton.becomeFirstResponder()
            return
        }
        
        BBRequestManager.shared.queryProducts(withSearchString: searchText, selectedCategoryID: limitedToCategoryWithID, currentPageNumber: currentPageNumber) { [weak self] success, responseProductsList in
            
            if let _ = BBFilterManager.shared.selectedTopLevelCategoryID
            {
                self?.setSearchButtonState(.showAllFromCategory)
            }
            else
            {
                self?.setSearchButtonState(.search)
            }
            
            guard let strongSelf = self,
                let responseProductsList = responseProductsList, success else
            {
                self?.setSearchButtonState(.noResults)
                return
            }
            strongSelf.productsList = responseProductsList
            
            DispatchQueue.main.async {
                strongSelf.tableView.reloadAnimated()
            }
        }
    }
}

//MARK: Extensions

//MARK: UISearchBarDelegate

extension BBSearchViewController: UISearchBarDelegate
{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        setSearchButtonState(.search)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        if searchBar.isFirstResponder
        {
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        currentPageNumber = 1
        
        guard searchText.characters.count == 0 else
        {
            return
        }
        
        if let _ = BBFilterManager.shared.selectedTopLevelCategoryID
        {
            setSearchButtonState(.showAllFromCategory)
        }
        else
        {
            setSearchButtonState(.search)
        }
    }
}

//MARK: UIScrollViewDelegate

extension BBSearchViewController: UIScrollViewDelegate
{
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        if ((tableView.contentOffset.y + tableView.frame.size.height) >= tableView.contentSize.height - productCellHeight * 2)
        {
            if let searchBarText = searchBar.text, searchBarText.characters.count > 0, !isHTTPRequestInProgress
            {
                isHTTPRequestInProgress = true
                
                setSearchButtonState(.loadingNextPage)
                
                BBRequestManager.shared.queryProducts(withSearchString: searchBarText, selectedCategoryID: BBFilterManager.shared.selectedTopLevelCategoryID, currentPageNumber: currentPageNumber) { [weak self] success, responseProductList in
                    
                    self?.isHTTPRequestInProgress = false
                    self?.setSearchButtonState(.search)
                    
                    guard let strongSelf = self, let responseProductList = responseProductList, success else
                    {
                        return
                    }
                    
                    DispatchQueue.main.async {
                    
                        strongSelf.currentPageNumber += 1
                        strongSelf.setSearchButtonState(.search)
                        strongSelf.tableView.beginUpdates()
                        
                        let insertIndex = strongSelf.productsList.count - 1
                        var indexPaths  : [IndexPath] = []
                            
                        for index in insertIndex...insertIndex + responseProductList.count - 1
                        {
                            indexPaths.append(IndexPath(row: index, section: 0))
                        }
                        
                        strongSelf.productsList.append(contentsOf: responseProductList)
                        
                        strongSelf.tableView.insertRows(at: indexPaths, with: .automatic)
                        strongSelf.tableView.endUpdates()
                        
                        strongSelf.tableView.setNeedsLayout()
                    }
                }
            }
        }
    }
}

//MARK: UITableViewDelegate

extension BBSearchViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedProduct = productsList[indexPath.row]
        performSegue(withIdentifier: productDetailSeque, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: UITableViewDataSource

extension BBSearchViewController: UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return ProductTableSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return productsList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        guard let section = ProductTableSection(rawValue: indexPath.section) else
        {
            return 0
        }
        
        switch section
        {
            case .list:
                return productCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let section = ProductTableSection(rawValue: indexPath.section) else
        {
            return tableView.dequeueReusableCell(withIdentifier: emptyCellID, for: indexPath)
        }
        
        switch section
        {
            case .list:
                let cell                    = tableView.dequeueReusableCell(withIdentifier: productCellID, for: indexPath) as? UITableViewCell
                let product                 = productsList[indexPath.row]
                
                cell?.textLabel?.text       = product.name
                
                if let sale_price = product.sale_price
                {
                    cell?.detailTextLabel?.text = "$\(sale_price.roundTo(places: 2))"
                }
                
                if let thumbnail_image_URL = product.thumbnail_image_URL
                {
                    cell?.imageView?.kf.setImage(with: URL(string: thumbnail_image_URL), placeholder: nil, options: nil, progressBlock: nil) { Image, error, cacheType, url in
                            
                        DispatchQueue.main.async {
                            cell?.setNeedsLayout()
                        }
                    }
                }
                
                cell?.imageView?.contentMode = .scaleAspectFit
                
                return cell!
        }
    }
}

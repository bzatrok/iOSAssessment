//
//  BBRequestManager.swift
//  BestBuy
//
//  Created by Ben Zatrok on 26/02/17.
//  Copyright © 2017 AmberGlass. All rights reserved.
//

import UIKit

class BBRequestManager
{
    //MARK: Variables
    
    //MARK: Initialization
    
    static let shared = BBRequestManager()
    private init() {}

    //MARK: Functions
    
    //MARK: PRODUCTS
    
    
    func queryProducts(withURL url: URL, completion: @escaping (_ success: Bool, _ responseProductList: [BBProduct]?) -> Void)
    {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard error == nil, let responseData = data else
            {
                print(error)
                completion(false, nil)
                return
            }
            
            do
            {
                guard let productsDict = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else
                {
                    print("error trying to convert data to JSON")
                    completion(false, nil)
                    return
                }
                
                if let productsArray = productsDict["products"] as? [[String : AnyObject]], productsArray.count > 0
                {
                    let productsList = BBObjectFactory.createProductsList(fromProductArray: productsArray)
                    completion(true, productsList)
                }
                else
                {
                    completion(true, nil)
                }
            }
            catch
            {
                print("error trying to convert data to JSON")
                completion(false, nil)
            }
        }
        
        task.resume()
    }
    
    /**
     Queries Products from Best Buy API using Search String
     
     - parameter searchString:  search string to search products against (optional)
     - parameter selectedCategoryID: category ID to filter products search into (optional)
     - parameter currentPageNumber: page number of search results, for pagination
     - parameter completion: completion block with success bool and optinal array of BBProducts return
     */
    func queryProducts(withSearchString searchString: String?, selectedCategoryID: String?, currentPageNumber: Int, completion: @escaping (_ success: Bool, _ responseProductList: [BBProduct]?) -> Void)
    {
        var URLString : String?
        
        if let searchString = searchString, let selectedCategoryID = selectedCategoryID
        {
            URLString = BBURLRoutes.productSearchAPIURL(searchString: searchString, selectedCategoryID: selectedCategoryID, currentPageNumber: currentPageNumber)
        }
        else if let searchString = searchString
        {
            URLString = BBURLRoutes.productSearchAPIURL(searchString: searchString, selectedCategoryID: nil, currentPageNumber: currentPageNumber)
        }
        else if let selectedCategoryID = selectedCategoryID
        {
            URLString = BBURLRoutes.productSearchAPIURL(searchString: nil, selectedCategoryID: selectedCategoryID, currentPageNumber: currentPageNumber)
        }
        
        guard let strongURLString = URLString,
            strongURLString.characters.count > 0,
            let URL = URL(string: strongURLString) else
        {
            completion(false, nil)
            return
        }
        
        queryProducts(withURL: URL, completion: completion)
    }
    
    /**
     Queries Products replated to a specific SKU, from the Best Buy API using an URL String

     - parameter completion: completion block with success bool and optinal array of BBProducts return
     */
    func queryProducts(withSKUs SKUs: [Int], completion: @escaping (_ success: Bool, _ responseProductList: [BBProduct]?) -> Void)
    {
        let URLString = BBURLRoutes.productsWithSKUs(skuList: SKUs)
        
        guard let URL = URL(string: URLString) else
        {
            completion(false, nil)
            return
        }
        
        queryProducts(withURL: URL, completion: completion)
    }
    
    //MARK: CATEGORIES
    
    /**
     Queries all top level Categories from Best Buy API
     
     - parameter completion: completion block with success bool and optinal array of BBCategories return
     */
    func queryCategories(currentPageNumber: Int, completion: @escaping (_ success: Bool, _ responseCategoryList: [BBCategory]?) -> Void)
    {
        guard let URL = URL(string: BBURLRoutes.allTopLevelCategoriesAPIURLWithPagination(currentPageNumber: currentPageNumber)) else
        {
            completion(false, nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: URL) { data, response, error in
            
            guard error == nil, let responseData = data else
            {
                print(error)
                completion(false, nil)
                return
            }
            
            do
            {
                guard let categoriesDict = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else
                {
                    print("error trying to convert data to JSON")
                    completion(false, nil)
                    return
                }
                
                if let categoriesArray = categoriesDict["categories"] as? [[String : AnyObject]]
                {
                    let categoriesList = BBObjectFactory.createCategoriesList(fromCategoriesArray: categoriesArray)
                    completion(true, categoriesList)
                }
                else
                {
                    completion(false, nil)
                }
            }
            catch
            {
                print("error trying to convert data to JSON")
                completion(false, nil)
            }
        }
        
        task.resume()
    }
}

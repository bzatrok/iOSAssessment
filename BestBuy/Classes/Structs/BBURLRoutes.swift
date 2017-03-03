//
//  BBURLRoutes.swift
//  BestBuy
//
//  Created by Ben Zatrok on 26/02/17.
//  Copyright © 2017 AmberGlass. All rights reserved.
//

import Foundation

struct BBURLRoutes
{
    //Base Routes
    static let baseAPIURL                   = "https://api.bestbuy.com/v1"
    static let productsAPIURL               = "\(baseAPIURL)/products"
    static let categoriesAPIURL             = "\(baseAPIURL)/categories"
    
    //All top level categories
    static func allTopLevelCategoriesAPIURLWithPagination(currentPageNumber: Int) -> String
    {
        return "\(categoriesAPIURL)(id=abcat*)?apiKey=\(BBConstants.APIKey)&pageSize=\(BBConstants.numberOfProductsPerPage)&show=id,name&format=json&page=\(currentPageNumber)"
    }
    
    static func productsWithSKUs(skuList: [Int]) -> String
    {
        let maxNumber       = skuList.count - 1 > 6 ? 6 : skuList.count - 1
        let limitedSKUList  = skuList[0..<maxNumber]
        let skuString       = limitedSKUList.map{ String(describing: $0) }.joined(separator: ",")
        
        return "\(productsAPIURL)(sku%20in%20(\(skuString)))?apiKey=\(BBConstants.APIKey)&sort=sku.asc&show=sku,name,shortDescription,regularPrice,salePrice,customerReviewAverage,customerReviewCount,onSale,image,thumbnailImage&format=json"
    }
    
    static func relatedProductsToProductWithSKU(SKU: Int) -> String
    {
        return "\(productsAPIURL)(sku%20in%20(\(SKU)))?apiKey=\(BBConstants.APIKey)&show=relatedProducts.sku&pageSize=50&format=json"
    }
    
    static func productSearchAPIURL(searchString: String?, selectedCategoryID: String?, currentPageNumber: Int) -> String
    {
        let selectedCategoryString  = selectedCategoryID != nil ? "(categoryPath.id=\(selectedCategoryID!))" : ""
        let selectedSearchString    = searchString != nil ? "(search=\(searchString!))" : ""
        let ampersand               = selectedCategoryString.characters.count > 0 && selectedSearchString.characters.count > 0 ? "&" : ""
        
        return "\(productsAPIURL)(\(selectedSearchString)\(ampersand)\(selectedCategoryString))?apiKey=\(BBConstants.APIKey)&sort=name.asc&show=name,categoryPath.id,categoryPath.name,shortDescription,sku,relatedProducts.sku,accessories.sku,thumbnailImage,image,customerReviewAverage,customerReviewCount,regularPrice,onSale,salePrice&pageSize=\(BBConstants.numberOfProductsPerPage)&format=json&page=\(currentPageNumber)"
    }
    
    
    
    static func categorySearchAPIURL(searchString: String, currentPageNumber: Int) -> String
    {
        return "\(categoriesAPIURL)((search=\(searchString.replacingOccurrences(of: " ", with: "&search=")))&)?apiKey=\(BBConstants.APIKey)&format=json&page=\(currentPageNumber)"
    }
}

//
//  BBProductFactory.swift
//  BestBuy
//
//  Created by Ben Zatrok on 27/02/17.
//  Copyright © 2017 AmberGlass. All rights reserved.
//

import Foundation

class BBObjectFactory
{
    //MARK: BBProduct
    
    static func createProductsList(fromProductArray productArray: [[String : AnyObject]]) -> [BBProduct]
    {
        let productsList : [BBProduct] = productArray.flatMap{
        
            guard let name = $0["name"] as? String else
            {
                return nil
            }
            
            var short_description = $0["shortDescription"] as? String != nil ? $0["shortDescription"] as? String : ""
            
            if let short_desc = short_description
            {
                short_description = short_desc.removeSpecialChars()
            }
            
            var relatedProductSKUList   : [Int] = []
            var accessorySKUList        : [Int] = []
            
            if let relatedProducts = $0["relatedProducts"] as? [[String : AnyObject]], relatedProducts.count > 0
            {
                relatedProductSKUList.append(contentsOf: relatedProducts.map { return $0["sku"] as? Int }.flatMap { $0 })
            }
            
            if let accessoryProducts = $0["accessories"] as? [[String : AnyObject]], accessoryProducts.count > 0
            {
                accessorySKUList = accessoryProducts.map { return $0["sku"] as? Int }.flatMap { $0 }
            }
            
            let productObject = BBProduct(_name: name.removeSpecialChars(),
                                          _sku: $0["sku"] as? Int,
                                          _regular_price: $0["regularPrice"] as? Double,
                                          _sale_price: $0["salePrice"] as? Double,
                                          _image_URL: $0["image"] as? String,
                                          _thumbnail_image_URL: $0["thumbnailImage"] as? String,
                                          _short_description: short_description,
                                          _customer_review_average: $0["customerReviewAverage"] as? Double,
                                          _customer_review_count: $0["customerReviewCount"] as? Int,
                                          _on_sale: $0["onSale"] as? Bool,
                                          _related_product_SKUs: relatedProductSKUList,
                                          _accessory_SKUs: accessorySKUList)
            
            return productObject
        }
        
        return productsList
    }
    
    //MARK: BBCategory
    
    static func createCategoriesList(fromCategoriesArray categoriesArray: [[String : AnyObject]]) -> [BBCategory]
    {
        let categoriesList : [BBCategory] = categoriesArray.flatMap {

            guard let name = $0["name"] as? String else
            {
                return nil
            }
            
            let categoryObject = BBCategory(_name: name, _id: $0["id"] as? String)
            
            return categoryObject
        }
        
        return categoriesList
    }
}

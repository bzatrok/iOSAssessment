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
        var productsList : [BBProduct] = []
        
        for productDictionary in productArray
        {
            guard let name = productDictionary["name"] as? String else
            {
                continue
            }
            
            var short_description = productDictionary["shortDescription"] as? String != nil ? productDictionary["shortDescription"] as? String : ""
            
            if let short_desc = short_description
            {
                short_description = short_desc.removeSpecialChars()
            }
            
            var accessorySKUList        : [Int] = []
            var relatedProductSKUList   : [Int] = []
            
            if let relatedProducts = productDictionary["relatedProducts"] as? [[String : AnyObject]], relatedProducts.count > 0
            {
                relatedProductSKUList   = relatedProducts.map{ if let sku = $0["sku"] as? Int { return sku }; return 0 }
            }
            
            if let accessoryProducts = productDictionary["accessories"] as? [[String : AnyObject]], accessoryProducts.count > 0
            {
                accessorySKUList        = accessoryProducts.map{ if let sku = $0["sku"] as? Int { return sku };  return 0 }
            }
            
            let productObject = BBProduct(_name: name.removeSpecialChars(),
                                          _sku: productDictionary["sku"] as? Int,
                                          _regular_price: productDictionary["regularPrice"] as? Double,
                                          _sale_price: productDictionary["salePrice"] as? Double,
                                          _image_URL: productDictionary["image"] as? String,
                                          _thumbnail_image_URL: productDictionary["thumbnailImage"] as? String,
                                          _short_description: short_description,
                                          _customer_review_average: productDictionary["customerReviewAverage"] as? Double,
                                          _customer_review_count: productDictionary["customerReviewCount"] as? Int,
                                          _on_sale: productDictionary["onSale"] as? Bool,
                                          _related_product_SKUs: relatedProductSKUList,
                                          _accessory_SKUs: accessorySKUList)
            
            productsList.append(productObject)
        }
        
        return productsList
    }
    
    //MARK: BBCategory
    
    static func createCategoriesList(fromCategoriesArray categoriesArray: [[String : AnyObject]]) -> [BBCategory]
    {
        var categoriesList : [BBCategory] = []
        
        for categoryDictionary in categoriesArray
        {
            guard let name = categoryDictionary["name"] as? String else
            {
                continue
            }
            
            let categoryObject = BBCategory(_name: name,
                                          _id: categoryDictionary["id"] as? String)
            
            categoriesList.append(categoryObject)
        }
        
        return categoriesList
    }
}

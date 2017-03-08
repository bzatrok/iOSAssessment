//
//  BBProduct.swift
//  BestBuy
//
//  Created by Ben Zatrok on 27/02/17.
//  Copyright © 2017 AmberGlass. All rights reserved.
//

import Foundation

class BBProduct : BBObject
{
    let sku : Int?
    let regular_price : Double?
    let sale_price : Double?
    let image_URL : String?
    let thumbnail_image_URL : String?
    let short_description : String?
    let customer_review_average : Double?
    let customer_review_count : Int?
    let on_sale : Bool?
    let related_product_SKUs : [Int]?
    let accessory_SKUs : [Int]?
    
    init(_name: String,
         _sku: Int?,
         _regular_price: Double?,
         _sale_price: Double?,
         _image_URL: String?,
         _thumbnail_image_URL: String?,
         _short_description: String?,
         _customer_review_average: Double?,
         _customer_review_count: Int?,
         _on_sale: Bool?,
         _related_product_SKUs: [Int]?,
         _accessory_SKUs: [Int]?)
    {
        sku                     = _sku
        regular_price           = _regular_price
        sale_price              = _sale_price
        image_URL               = _image_URL
        thumbnail_image_URL     = _thumbnail_image_URL
        short_description       = _short_description
        customer_review_average = _customer_review_average
        customer_review_count   = _customer_review_count
        on_sale                 = _on_sale
        related_product_SKUs    = _related_product_SKUs
        accessory_SKUs          = _accessory_SKUs
        
        super.init(object_name: _name)
    }
}

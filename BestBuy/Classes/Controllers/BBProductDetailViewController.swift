//
//  BBProductDetailViewController.swift
//  BestBuy
//
//  Created by Ben Zatrok on 27/02/17.
//  Copyright © 2017 AmberGlass. All rights reserved.
//

import UIKit

class BBProductDetailViewController: UIViewController
{
    //MARK: Variables
    
    var selectedProduct                         : BBProduct?
    
    let relatedProductsListSegue                = "relatedProductsListSegue"
    let accessoryProductGridSegue               = "accessoryProductGridSegue"
    
    //MARK: IBOutlets
    
    @IBOutlet weak var headerImageView          : UIImageView!
    @IBOutlet weak var onSaleView               : UIView! {
        didSet {
            onSaleView.layer.cornerRadius   = onSaleView.frame.height / 2
            onSaleView.backgroundColor      = BBColors.red
        }
    }
    @IBOutlet weak var onSaleLabel              : UILabel!
    @IBOutlet weak var productNameLabel         : UILabel!
    @IBOutlet weak var productDescriptionLabel  : UILabel!
    @IBOutlet weak var productRatingCountLabel  : UILabel!
    @IBOutlet weak var productSalePriceLabel    : UILabel!
    @IBOutlet weak var productRetailPriceLabel  : UILabel!
    
    @IBOutlet weak var accessoriesButton        : UIButton! {
        didSet {
            accessoriesButton.setTitle("Accessories", for: .normal)
            
            if let selectedProduct = selectedProduct, let accessory_SKUs = selectedProduct.accessory_SKUs, accessory_SKUs.count > 0
            {
                accessoriesButton.setBackgroundImage(UIImage(color: BBColors.red), for: .normal)
            }
            else
            {
                accessoriesButton.setBackgroundImage(UIImage(color: BBColors.grey), for: .normal)
            }
        }
    }
    
    @IBOutlet weak var relatedProductsButton    : UIButton! {
        didSet {
            relatedProductsButton.setTitle("Related Products", for: .normal)
            
            if let selectedProduct = selectedProduct, let related_product_SKUs = selectedProduct.related_product_SKUs, related_product_SKUs.count > 0
            {
                relatedProductsButton.setBackgroundImage(UIImage(color: BBColors.blue), for: .normal)
            }
            else
            {
                relatedProductsButton.setBackgroundImage(UIImage(color: BBColors.grey), for: .normal)
            }
        }
    }
    
    //MARK: IBActions
    
    @IBAction func accessoriesButtonClicked(_ sender: Any)
    {
        guard let selectedProduct = selectedProduct, let accessory_SKUs = selectedProduct.accessory_SKUs, accessory_SKUs.count > 0 else
        {
            let noAccessoriesAlert = UIAlertController(title: "No Accessories found for this product", message: "This product has no accessories on record.", preferredStyle: .alert)
            
            noAccessoriesAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(noAccessoriesAlert, animated: true, completion: nil)
            
            return
        }
        
        performSegue(withIdentifier: accessoryProductGridSegue, sender: self)
    }
    
    @IBAction func relatedProductsButtonClicked(_ sender: Any)
    {
        guard let selectedProduct = selectedProduct, let related_product_SKUs = selectedProduct.related_product_SKUs, related_product_SKUs.count > 0 else
        {
            let noRelatedProductAlert = UIAlertController(title: "No Accessories found for this product", message: "This product has no accessories on record.", preferredStyle: .alert)
            
            noRelatedProductAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            present(noRelatedProductAlert, animated: true, completion: nil)
            
            return
        }
        
        performSegue(withIdentifier: relatedProductsListSegue, sender: self)
    }
    
    //MARK: Life-Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupView()
    }
    
    //MARK: Functions
    
    func setupView()
    {
        guard let selectedProduct = selectedProduct else
        {
            navigationController?.popViewController(animated: true)
            return
        }
        
        if let image_URL = selectedProduct.image_URL
        {
            headerImageView.kf.setImage(with: URL(string: image_URL))
            headerImageView.contentMode = .scaleAspectFit
        }
        
        productNameLabel.text           = selectedProduct.name
        productDescriptionLabel.text    = selectedProduct.short_description != nil ? selectedProduct.short_description : ""
        
        if let customer_review_average = selectedProduct.customer_review_average, let customer_review_count = selectedProduct.customer_review_count
        {
            productRatingCountLabel.text = "Rated \(customer_review_average) on average, by \(customer_review_count) customers"
        }
        else
        {
            productRatingCountLabel.text = "Not yet rated"
        }
        
        onSaleView.isHidden = true
        
        if let on_sale = selectedProduct.on_sale
        {
            onSaleView.isHidden = !on_sale
        }
        
        onSaleLabel.text = "On Sale!"
        
        if let sale_price = selectedProduct.sale_price
        {
            productSalePriceLabel.text = "$\(sale_price.roundTo(places: 2))"
        }
    
        productRetailPriceLabel.isHidden = false
        
        if selectedProduct.sale_price != selectedProduct.regular_price
        {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "$\(selectedProduct.regular_price!.roundTo(places: 2))")
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
            
            productRetailPriceLabel.attributedText  = attributeString
        }
        else
        {
            productRetailPriceLabel.isHidden = true
        }
    }
    
    //MARK: Segue handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let selectedProduct = selectedProduct,
            let destination = segue.destination as? BBListSelectorViewController,
            segue.identifier == relatedProductsListSegue
        {
            destination.SKUList         = selectedProduct.related_product_SKUs
            destination.currentState    = .relatedProducts
        }
        else if let selectedProduct = selectedProduct,
            let destination = segue.destination as? BBGridSelectorViewController,
            segue.identifier == accessoryProductGridSegue
        {
            destination.SKUList         = selectedProduct.accessory_SKUs
        }
    }
}

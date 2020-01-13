//
//  PriceSearchWebViewController.swift
//  Comp Sci Culminating
//
//  Created by Anant Prakash on 2019-06-13.
//  Copyright © 2019 Anant. All rights reserved.
//

import UIKit
import WebKit
class PriceSearchWebViewController: UIViewController  {

   var itemName = ""
    

    @IBOutlet weak var priceSearchWeb: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Loads website using item found. 
        let itemToSearch = itemName.replacingOccurrences(of: " ", with: "+")
        let urlString = "http://www.pricegrabber.com/\(itemToSearch)/products/"
        let site = URL(string: urlString)
        let siteRequest = URLRequest(url: site!)
        self.priceSearchWeb.load(siteRequest)
        print(itemToSearch)
    }
   
}

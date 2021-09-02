//
//  ViewController.swift
//  IPromote
//
//  Created by a0k07j2 on 8/31/21.
//

import UIKit
import CoreLocation
import WebKit

class ViewController: UIViewController, WKUIDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    
    func loadWebView() {
        webView.uiDelegate = self
        let myURL = URL(string:"https://www.walmart.com")
               let myRequest = URLRequest(url: myURL!)
               webView.load(myRequest)
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadWebView()
    }

}


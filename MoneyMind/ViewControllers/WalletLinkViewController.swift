//
//  WalletLinkViewController.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 18/5/21.
//

import UIKit
import StoreKit

class WalletLinkViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let wallet = URL(string: "shoebox://") else{return}
        if UIApplication.shared.canOpenURL(wallet)
        {
        //deeplink to wallets app
            UIApplication.shared.open(wallet, options: [:] , completionHandler: nil)
        }
        else
        {
        //upsell app
            let vc = SKStoreProductViewController()
            vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier : NSNumber(value: 1160481993)], completionBlock: nil)
            present(vc, animated: true)
        }
    }

}

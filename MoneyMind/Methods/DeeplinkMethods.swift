//
//  DeeplinkMethods.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 1/6/21.
//

import Foundation
import StoreKit
import UIKit

class DeeplinkMethods: UIViewController
{
    func accessWallet()
    {
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

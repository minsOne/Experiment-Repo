//
//  PaymentJSPlugin.swift
//  SampleApp
//
//  Created by minsOne on 5/11/24.
//

import Foundation
import WebKit

class PaymentJSPlugin: JSInterfacePluggable {
    let action = "payment"
    
    func callAsAction(_ message: [String: Any], with webView: WKWebView) {
        guard
            let result = Parser(message)
        else { return }
        
        closure?(result.info, webView)
    }
    
    func set(_ closure: @escaping (Info, WKWebView) -> Void) {
        self.closure = closure
    }
    
    private var closure: ((Info, WKWebView) -> Void)?
}

extension PaymentJSPlugin {
    struct Info {
        let uuid: String
        let paymentAmount: Int
        let paymentTransactionId: String
        let paymentId: String
        let paymentGoodsName: String
    }
}

private extension PaymentJSPlugin {
    struct Parser {
        let info: Info
        
        init?(_ dictonary: [String: Any]) {
            guard
                let uuid = dictonary["uuid"] as? String,
                let body = dictonary["body"] as? [String: Any],
                let paymentAmount = body["paymentAmount"] as? Int,
                let paymentTransactionId = body["paymentTransactionId"] as? String,
                let paymentId = body["paymentId"] as? String,
                let paymentGoodsName = body["paymentGoodsName"] as? String
            else { return nil }
            
            info = .init(
                uuid: uuid,
                paymentAmount: paymentAmount,
                paymentTransactionId: paymentTransactionId,
                paymentId: paymentId,
                paymentGoodsName: paymentGoodsName
            )
        }
    }
}

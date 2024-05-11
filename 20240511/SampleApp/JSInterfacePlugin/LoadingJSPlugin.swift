//
//  LoadingJSPlugin.swift
//  SampleApp
//
//  Created by minsOne on 5/11/24.
//

import Foundation
import WebKit

class LoadingJSPlugin: JSInterfacePluggable {
    let action = "loading"
    
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

extension LoadingJSPlugin {
    struct Info {
        let uuid: String
        let isShow: Bool
    }
}

private extension LoadingJSPlugin {
    struct Parser {
        let info: Info
        
        init?(_ dictonary: [String: Any]) {
            guard
                let uuid = dictonary["uuid"] as? String,
                let body = dictonary["body"] as? [String: Any],
                let isShow = body["isShow"] as? Bool
            else { return nil }
            
            info = .init(uuid: uuid, isShow: isShow)
        }
    }
}

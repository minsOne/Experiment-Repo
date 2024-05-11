//
//  JSInterfacePluggable.swift
//  SampleApp
//
//  Created by minsOne on 5/11/24.
//

import WebKit

protocol JSInterfacePluggable {
    var action: String { get }
    func callAsAction(_ message: [String: Any], with: WKWebView)
}

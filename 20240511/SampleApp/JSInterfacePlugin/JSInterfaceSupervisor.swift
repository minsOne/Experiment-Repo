//
//  JSInterfaceSupervisor.swift
//  SampleApp
//
//  Created by minsOne on 5/11/24.
//

import Foundation
import WebKit

/// Supervisor class responsible for loading and managing JS plugins.
class JSInterfaceSupervisor {
    var loadedPlugins = [String: JSInterfacePluggable]()

    public init() {}
}

extension JSInterfaceSupervisor {
    /// Loads a single plugin into the supervisor.
    func loadPlugin(_ plugin: JSInterfacePluggable) {
        let action = plugin.action

        guard loadedPlugins[action] == nil else {
            assertionFailure("\(action) action already exists. Please check the plugin.")
            return
        }

        loadedPlugins[action] = plugin
    }

    /// Loads multiple plugins into the supervisor.
    func loadPlugin(contentsOf newElements: [JSInterfacePluggable]) {
        newElements.forEach { loadPlugin($0) }
    }
}

extension JSInterfaceSupervisor {
    /// Resolves an action and calls the corresponding plugin with a message and web view.
    func resolve(_ action: String, message: [String: Any], with webView: WKWebView) {
        guard
            let plugin = loadedPlugins[action],
            plugin.action == action
        else {
            assertionFailure("Failed to resolve \(action): Action is not loaded. Please ensure the plugin is correctly loaded.")
            return
        }

        plugin.callAsAction(message, with: webView)
    }
}

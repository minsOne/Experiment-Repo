//
//  ViewController.swift
//  SampleApp
//
//  Created by minsOne on 5/5/24.
//

import OSLog
import UIKit
import WebKit

class ViewController: UIViewController {
    private let supervisor = JSInterfaceSupervisor()

    var webView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()

        initPlugins()
        initWebView()
    }
}

extension ViewController {
    func initPlugins() {
        let loadingPlugin = LoadingJSPlugin()
        let paymentPlugin = PaymentJSPlugin()
        loadingPlugin.set { info, webView in
            print("LoadingPlugin :", info)
        }
        paymentPlugin.set { info, webView in
            print("PaymentJSPlugin :", info)
        }

        supervisor.loadPlugin(contentsOf: [loadingPlugin, paymentPlugin])
    }
}

extension ViewController: WKScriptMessageHandler {
    // WKScriptMessageHandler 프로토콜 메서드 구현
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard
            message.name == "actionHandler",
            let messageBody = message.body as? [String: Any],
            let action = messageBody["action"] as? String
        else { return }

        print("Received message from JavaScript: \(messageBody)") // 웹으로부터 받은 메시지를 파싱하여 print를 호출하는 코드.

        guard let webView else { return }

        supervisor.resolve(action, message: messageBody, with: webView)
    }
}

private extension ViewController {
    func initWebView() {
        // WKUserContentController 인스턴스 생성
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "actionHandler") // 메시지 핸들러 등록

        // WKWebView에 WKUserContentController 설정
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController

        // WKWebView 인스턴스 생성
        let webView = WKWebView(frame: view.bounds, configuration: configuration)
        self.webView = webView

        // WKWebView를 뷰에 추가
        view.addSubview(webView)

        // HTML 파일 로드
        if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html") {
            let url = URL(fileURLWithPath: htmlPath)
            webView.loadFileURL(url, allowingReadAccessTo: url)
        }
    }
}

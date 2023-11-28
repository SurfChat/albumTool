//
//  PhotoWebViewController.swift
//  SurfTool
//
//  Created by Phenou on 28/11/2023.
//

import UIKit
import WebKit

class PhotoWebViewController: UIViewController {
    
    var request: URLRequest!
    
    lazy var webView: WKWebView = {
        let ww = WKWebView()
        ww.allowsBackForwardNavigationGestures = true
        ww.navigationDelegate = self
        return ww
    }()
    
    convenience init(url: String?) {
        self.init()
        self.request = URLRequest(url: URL(string: url ?? "")!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        webView.load(request)
        
    }
}

extension PhotoWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title ?? ""
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
}

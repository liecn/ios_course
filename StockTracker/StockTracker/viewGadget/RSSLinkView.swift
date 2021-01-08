//
//  RSSLinkView.swift
//  StockTracker
//
//  Created by Chenning Li on 12/8/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import SwiftUI
import WebKit

struct RSSLinkView: UIViewRepresentable {
 
    let  url: URL?
   
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        webView.load(URLRequest(url: url!))
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        
    }
    
    
}

struct RSSLinkView_Previews: PreviewProvider {
    static var previews: some View {
        RSSLinkView(url: URL(string: "https://finance.yahoo.com/news/europe-pins-hopes-smarter-coronavirus-111118443.html?.tsrc=rss"))
    }
}

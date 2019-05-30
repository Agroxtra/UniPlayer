//
//  YoutubeDownloader.swift
//  UniPlayer
//
//  Created by Martin Zörfuss on 30.05.19.
//  Copyright © 2019 Martin Zörfuss. All rights reserved.
//

import UIKit
import WebKit

class YoutubeDownloader : NSObject, WKNavigationDelegate {
    private var completion : ((_ file: URL) -> Void)?
    private var id: String = ""
    
    func download(id: String, completion: @escaping (_ file: URL)->Void) {
        self.completion = completion
        self.id = id
        
        let web = WKWebView(frame: .zero)
        web.navigationDelegate = self
        web.load(URLRequest(url: URL(string: "https://convertmp3.io/widget/button/?video=https://www.youtube.com/watch?v=\(id)&format=mp3&text=ffffff&color=3880f3")!))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.getElementById(\"downloadButton\").href;") { (result, error) in
            if let error = error {
                print(error)
            } else if let urlStr = result as? String,
                let url = URL(string: urlStr)
            {
                let session = URLSession.shared
                let req = session.dataTask(with: url){data, resp, err in
                    if let err = err {
                        print(err)
                    } else if let resp = resp as? HTTPURLResponse,
                        resp.statusCode == 200,
                        let data = data
                    {
                        var path = AppFile().libraryDirectoryURL()
                        path.appendPathComponent(self.id)
                        path.appendPathExtension("mp3")
                        FileManager().createFile(atPath: path.absoluteString, contents: data, attributes: nil)
                        self.completion?(path)
                    }
                }
                req.resume()
            }
        }
    }
}

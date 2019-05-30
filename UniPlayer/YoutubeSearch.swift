//
//  YoutubeSearch.swift
//  UniPlayer
//
//  Created by Lukas Putz on 30.05.19.
//  Copyright © 2019 Martin Zörfuss. All rights reserved.
//

import Foundation

class YoutubeSearch {
    
    func search(searchString: String, completion: @escaping (_ items: [YoutubeSearchItem]) -> Void){
        var urlcomps = URLComponents(string: "https://www.googleapis.com/youtube/v3/search")
        let queryItems = [URLQueryItem(name: "part", value: "snippet"),
                          URLQueryItem(name: "q", value: searchString),
                          URLQueryItem(name: "type", value: "video"),
                          URLQueryItem(name: "key", value: YouTubeAPIKey.key)]
        urlcomps?.queryItems = queryItems
        let url: URL = urlcomps!.url!
        print(url.absoluteString)
        
        let session = URLSession.shared
        let req = session.dataTask(with: url){data, resp, error in
            if let err = error {
                print(err)
            } else if let data = data,
                let resp = resp as? HTTPURLResponse,
                resp.statusCode == 200
            {
                if let dataString = String(data: data, encoding: .utf8),
                   let dict = Utilities.convertStringToDictionary(text: dataString) {
                    let items = dict["items"] as! [[String: AnyObject]]
                    var ytsearchitems = [YoutubeSearchItem]()
                    for item in items{
                        let id = item["id"] as! [String: AnyObject]
                        let snippet = item["snippet"] as! [String: AnyObject]
                        print("ID: \(id["videoId"]!)  title: \(snippet["title"]!)")
                        ytsearchitems.append(YoutubeSearchItem(title: snippet["title"] as! String, fileName: id["videoId"] as! String))
                    }
                    completion(ytsearchitems)
                }
            }
        }
        req.resume()
    }

}


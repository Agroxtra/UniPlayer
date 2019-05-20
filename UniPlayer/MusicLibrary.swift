//
//  MusicLibrary.swift
//  MusicPlayer
//
//  Created by Martin Zörfuss on 19.05.19.
//  Copyright © 2019 Martin Zörfuss. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class MusicLibrary {
    static var library = [Music]()
}


struct Music {
    let artist : String?
    let url : URL
    let title : String
    let artwork : UIImage?
}

extension Music{
    init(path: URL){
        
        url = path
        
        let playerItem = AVPlayerItem(url: path)
        let metadataList = playerItem.asset.metadata
        
        var titleName : String?
        var artistName : String?
        var artworkImage : UIImage?
        
        for item in metadataList {
            
            guard let key = item.commonKey?.rawValue, let value = item.value else{
                continue
            }
            
            switch key {
            case "title" :
               titleName = value as? String
            case "artist":
                artistName = value as? String
            case "artwork" where value is Data : artworkImage = UIImage(data: value as! Data)
            default:
                continue
            }
        }
        
        if let t = titleName {
            title = t
        } else {
            title = url.lastPathComponent
        }
        artist = artistName
        artwork = artworkImage
    }
    
    func getArtwork(size: CGSize) -> UIImage{
        if let a = artwork {
            return a
        }
        return UIImage(named: "musicnote")!
    }
}


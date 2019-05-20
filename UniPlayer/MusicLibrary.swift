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
    static var library = [Song]()
    static var playlists = [Playlist]()
    static var player = Player()
    
    static func loadLibrary(){
        // MARK: create readme file creates directory for App
        let file = AppFile()
        try? FileManager.default.createDirectory(at: AppFile().songsDirectoryURL(), withIntermediateDirectories: true, attributes: nil)
        _ = file.writeFile(containing: "Put all your mp3 files here and they will be recognized after relaunching the application. Then you can play them as you wish.", to: .Songs, withName: "readme.txt")
        
        MusicLibrary.library.removeAll()
        
        // MARK: read all files from Documents directory and filter them by extension mp3
        let files = AppFile().getFileUrls(directory: AppFile().songsDirectoryURL())
        for url in files {
            if url.isFileURL && url.pathExtension == "mp3" {
                // MARK: add mp3 files to library, which is used for playing music
                MusicLibrary.library.append(Song(path: url))
            }
        }
    }
    
    static func loadPlaylists(){
        
        try? FileManager.default.createDirectory(at: AppFile().playlistsDirectoryURL(), withIntermediateDirectories: true, attributes: nil)
        _ = AppFile().writeFile(containing: "This directory contains configuration of your playlists. Do NOT modify the file unless you know what you are doing!", to: .Playlists, withName: "DO_NOT_MODIFY.txt")
        
        MusicLibrary.playlists.removeAll()
        parsePlaylists()
    }
    
    static func load(){
        loadLibrary()
        loadPlaylists()
    }
    
    private static func parsePlaylists(){
        let str = AppFile().readFile(at: .Playlists, withName: "playlists.json")
        guard let dict = Utilities.convertStringToDictionary(text: str),
            let playlists = dict["playlists"] as? [[String: Any]] else {
            print("playlists.json file invalid!")
            return
        }
        playlists.forEach { (elem) in
            print(elem)
        }
        
        
    }
}


struct Song : Equatable{
    let artist : String?
    let url : URL
    let title : String
    let artwork : UIImage?
    
    static func ==(s1: Song, s2: Song) -> Bool{
        return s1.url == s2.url
    }
}

extension Song {
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
    
    func getArtwork() -> UIImage {
        if let a = artwork {
            return a
        } else {
            return UIImage(named: "musicnote")!
        }
    }
    
    func getArtwork(size: CGSize) -> UIImage{
        if let a = artwork {
            return resizeImage(image: a, targetSize: size)
        }
        return resizeImage(image: UIImage(named: "musicnote")!, targetSize: size)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}


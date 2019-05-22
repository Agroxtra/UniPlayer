//
//  Playlist.swift
//  UniPlayer
//
//  Created by Lukas Putz on 20.05.19.
//  Copyright © 2019 Martin Zörfuss. All rights reserved.
//

import Foundation

class Playlist{
    private var _list: [Song] = []
    public var name: String
    public var lastPlayed: Date
    
    init(name: String){
        self.name = name
        lastPlayed = Date()
    }
    
    init(name: String, lastPlayed: Date){
        self.name = name
        self.lastPlayed = lastPlayed
    }
    
    static func createFrom(dict: [String:AnyObject]) -> Playlist?{
        var name: String?
        var lastPlayed: Date?
        if let n = dict["name"] as? String{
            name = n
        }
        if let s = dict["lastPlayed"] as? String,
            let date = ISO8601DateFormatter().date(from: s){
            lastPlayed = date
        }
        
        var songList = [PlaylistItem]()
        
        for song in dict["songs"] as! [[String:AnyObject]] {
            let item = PlaylistItem(songIndex: song["songIndex"] as! Int, source: song["songSource"] as! String, url: song["songURL"] as! String)
            songList.append(item)
        }
        
        
        if let n = name, let l = lastPlayed{
            let pl = Playlist(name: n, lastPlayed: l)
            songList.sort { (s1, s2) -> Bool in
                return s1.songIndex < s2.songIndex
            }
            for item in songList{
                pl.addSong(song: Song(path: AppFile().songsDirectoryURL().appendingPathComponent(item.url)))
            }
            return pl
        } else {
            return nil
        }
        
    }
    
    
    public var list: [Song]{
        get {
            return _list
        }
    }
    
    func addSong(song: Song){
        _list.append(song)
    }
    
    func removeSong(song: Song){
        while let i = _list.firstIndex(of: song){
            _list.remove(at: i)
        }
    }
    
    func removeSong(atIndex: Int){
        _list.remove(at: atIndex)
    }
    
    func savePlaylist() -> [String:AnyObject]{
        var pl: [String:AnyObject] = [:]
        pl["name"] = name as AnyObject
        pl["lastPlayed"] = ISO8601DateFormatter().string(from: lastPlayed) as AnyObject
        var songArray: [[String:AnyObject]] = []
        var i = 0
        for song in list{
            var songDict: [String:AnyObject] = [:]
            songDict["songIndex"] = i as AnyObject
            i += 1
            songDict["songSource"] = song.sourceType.rawValue as AnyObject
            songDict["songURL"] = song.url.lastPathComponent as AnyObject
            songArray.append(songDict)
        }
        pl["songs"] = songArray as AnyObject
        return pl
    }
    
}

struct PlaylistItem {
    var songIndex: Int
    var source: String
    var url: String
}

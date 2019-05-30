//
//  Playlist.swift
//  UniPlayer
//
//  Created by Lukas Putz on 20.05.19.
//  Copyright © 2019 Martin Zörfuss. All rights reserved.
//

import UIKit

class Playlist : Equatable {
    private var _list: [Song] = []
    public var name: String
    public var lastPlayed: Date
    private var youtubeDownloader = YoutubeDownloader()
    public lazy var image : UIImage = self.createArtwork()
    
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
        if let _ = _list.firstIndex(of: song) {
            print("Playlist \(self.name) already contains Song \(song.title)\n It will not be added again!")
        } else {
            _list.append(song)
            MusicLibrary.savePlaylists()
            
            //MARK: update artwork
            self.image = self.createArtwork()
        }
    }
    
    func removeSong(song: Song){
        while let i = _list.firstIndex(of: song){
            _list.remove(at: i)
        }
        MusicLibrary.savePlaylists()
        
        // MARK: update artwork
        self.image = self.createArtwork()
    }
    
    func removeSong(atIndex: Int){
        _list.remove(at: atIndex)
        MusicLibrary.savePlaylists()
        
        // MARK: update artwork
        self.image = self.createArtwork()
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
    
    static func ==(lhs: Playlist, rhs: Playlist) -> Bool{
        return lhs.name == rhs.name
    }
    
    private func createArtwork() -> UIImage {
        if self._list.count > 0 {
            if self._list.count < 4 {
                let firstWithImg = self._list.filter({ (song) -> Bool in
                    return song.artwork != nil
                }).first?.artwork
                
                if let img = firstWithImg {
                    return img
                }
            } else {
                let img1 = self._list.first!.getArtwork()
                let img2 = self._list[1].getArtwork()
                let img3 = self._list[2].getArtwork()
                let img4 = self._list[3].getArtwork()
                let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 400, height: 400)))
                let imgView1 = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 200)))
                imgView1.contentMode = .scaleAspectFit
                imgView1.image = img1
                view.addSubview(imgView1)
                let imgView2 = UIImageView(frame: CGRect(origin: CGPoint(x: 200, y: 0), size: CGSize(width: 200, height: 200)))
                imgView2.contentMode = .scaleAspectFit
                imgView2.image = img2
                view.addSubview(imgView2)
                let imgView3 = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 200), size: CGSize(width: 200, height: 200)))
                imgView3.contentMode = .scaleAspectFit
                imgView3.image = img3
                view.addSubview(imgView3)
                let imgView4 = UIImageView(frame: CGRect(origin: CGPoint(x: 200, y: 200), size: CGSize(width: 200, height: 200)))
                imgView4.contentMode = .scaleAspectFit
                imgView4.image = img4
                view.addSubview(imgView4)
                
                UIGraphicsBeginImageContext(view.bounds.size)
                view.layer.render(in: UIGraphicsGetCurrentContext()!)
                let image = UIGraphicsGetImageFromCurrentImageContext()
                
                UIGraphicsEndImageContext()
                
                return image ?? UIImage(named: "musicnote")!
            }
        }
        return UIImage(named: "musicnote")!
    }
    
    func addSong(youtubeId: String) {
        youtubeDownloader.download(id: youtubeId) { (file) in
            self.addSong(song: Song(path: file))
        }
    }
    
}

struct PlaylistItem {
    var songIndex: Int
    var source: String
    var url: String
}

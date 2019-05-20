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
    
}

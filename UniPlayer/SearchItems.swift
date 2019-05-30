//
//  SearchItem.swift
//  UniPlayer
//
//  Created by Martin Zörfuss on 30.05.19.
//  Copyright © 2019 Martin Zörfuss. All rights reserved.
//

import Foundation

class SearchItem : Equatable {
    var title: String
    var fileName: String
    
    init(title: String, fileName: String) {
        self.title = title
        self.fileName = fileName
    }
    
    static func == (lhs: SearchItem, rhs: SearchItem) -> Bool {
        return lhs.fileName == rhs.fileName
    }
}


class YoutubeSearchItem : SearchItem {
    var downloader: YoutubeDownloader?
    
    func getSong(completion: @escaping (_ file : URL) -> Void){
        if self.downloader == nil {
            self.downloader = YoutubeDownloader()
        }
        self.downloader?.download(id: self.fileName, completion: completion)
    }
}

class LocalSearchItem : SearchItem {
    func getSong() -> Song {
        return Song(path: AppFile().songsDirectoryURL().appendingPathComponent(fileName).appendingPathExtension("mp3"))
    }
    
    func conformsToSearch(for search: String)->Bool{
        return self.title.lowercased().contains(search.lowercased())
    }
}

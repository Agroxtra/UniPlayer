//
//  MusicLibrary.swift
//  MusicPlayer
//
//  Created by Martin Zörfuss on 19.05.19.
//  Copyright © 2019 Martin Zörfuss. All rights reserved.
//

import Foundation

class MusicLibrary {
    static var library = [Music]()
}


struct Music {
    let artist : String?
    let url : URL
    let title : String
}

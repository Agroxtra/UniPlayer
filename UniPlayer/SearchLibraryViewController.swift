//
//  SearchLibraryViewController.swift
//  UniPlayer
//
//  Created by Martin Zörfuss on 22.05.19.
//  Copyright © 2019 Martin Zörfuss. All rights reserved.
//

import UIKit

class SearchLibraryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // TODO: add support for mulitple sources
    @IBOutlet weak var tableView: UITableView!
    public var playlistIndex: Int!
    
    private var songsToAdd = [Int]()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MusicLibrary.library.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "musicCell")
        cell.textLabel?.text = MusicLibrary.library[indexPath.row].title
        cell.detailTextLabel?.text = MusicLibrary.library[indexPath.row].artist
        
        
        cell.imageView?.image = Utilities.createIcon(for: MusicLibrary.library[indexPath.row].getArtwork(size: CGSize(width: 200, height: 200)), imageView: cell.imageView ?? UIImageView(), background: .clear, imgFactor: 0.95, cornerRadius: 10)
        
        if let _ = self.songsToAdd.firstIndex(of: indexPath.row) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        DispatchQueue.main.async {
            if let i = self.songsToAdd.firstIndex(of: indexPath.row) {
                self.songsToAdd.remove(at: i)
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
            } else {
                self.songsToAdd.append(indexPath.row)
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.songsToAdd.map({ (index) -> Song in
            return MusicLibrary.library[index]
        }).forEach { (song) in
            MusicLibrary.playlists[self.playlistIndex].addSong(song: song)
        }
        
        DispatchQueue.main.async {
             self.navigationController?.dismiss(animated: true, completion: nil)
        }
       
    }
}

//
//  PlaylistItemTableViewController.swift
//  UniPlayer
//
//  Created by Martin Zörfuss on 21.05.19.
//  Copyright © 2019 Martin Zörfuss. All rights reserved.
//

import UIKit

class PlaylistItemTableViewController : UITableViewController {
    public var playlistIndex : Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = MusicLibrary.playlists[playlistIndex].name
        
        // MARK: setup add button (UIBarButtonItem)
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonPressed(_:)))
        self.navigationItem.setRightBarButton(addBtn, animated: false)
        
        //MARK: setup edit button (UIBarButtonItem)
        let editBtn = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editButtonPressed(_:)))
        self.navigationItem.setLeftBarButton(editBtn, animated: false)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MusicLibrary.playlists[self.playlistIndex].list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "musicCell")
        
        let song = MusicLibrary.playlists[self.playlistIndex].list[indexPath.row]
        
        cell.textLabel?.text = song.title
        cell.detailTextLabel?.text = song.artist
        cell.imageView?.image = Utilities.createIcon(for: song.getArtwork(size: CGSize(width: 200, height: 200)), imageView: cell.imageView ?? UIImageView(), background: .clear, imgFactor: 0.95, cornerRadius: 10)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MusicLibrary.player.queue = MusicLibrary.playlists[self.playlistIndex].list
        MusicLibrary.player.playSong(index: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @objc
    private func addButtonPressed(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Add Song", message: "This method is not implemented yet", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok…", style: .default, handler: { (_) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc
    private func editButtonPressed(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Edit Playlist", message: "This method is not implemented yet", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok…", style: .default, handler: { (_) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

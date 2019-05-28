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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            if self.tableView != nil {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = MusicLibrary.playlists[playlistIndex].name
        
        // MARK: setup add button (UIBarButtonItem)
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonPressed(_:)))
        self.navigationItem.setRightBarButton(addBtn, animated: false)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MusicLibrary.playlists[self.playlistIndex].list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "musicCell")
        
        let song = MusicLibrary.playlists[self.playlistIndex].list[indexPath.row]
        
        cell.textLabel?.text = song.title
        cell.detailTextLabel?.text = song.artist
        cell.imageView?.image = Utilities.addBorder(for: song.getArtwork(size: CGSize(width: 200, height: 200)), imageView: cell.imageView ?? UIImageView(), background: .clear, imgFactor: 0.95, cornerRadius: 10)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MusicLibrary.player.queue = MusicLibrary.playlists[self.playlistIndex].list
        MusicLibrary.player.playSong(index: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            MusicLibrary.playlists[self.playlistIndex].removeSong(atIndex: indexPath.row)
            DispatchQueue.main.async {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    @objc
    private func addButtonPressed(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            guard let nvc = self.storyboard?.instantiateViewController(withIdentifier: "addSongVC") as? UINavigationController,
                let rootVC = nvc.viewControllers.first as? SearchLibraryViewController else
            {
                fatalError("Storyboard has to contain a \"addSongVC\" View Controller")
            }
            rootVC.playlistIndex = self.playlistIndex
            self.present(nvc, animated: true, completion: nil)
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

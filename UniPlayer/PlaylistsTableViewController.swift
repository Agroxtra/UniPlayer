//
//  PlaylistsTableViewController.swift
//  UniPlayer
//
//  Created by Martin Zörfuss on 21.05.19.
//  Copyright © 2019 Martin Zörfuss. All rights reserved.
//

import UIKit

class PlaylistsTableViewController : UITableViewController, PlayerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if !MusicLibrary.isLoaded {
//            MusicLibrary.load()
//            self.tableView.reloadData()
//        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MusicLibrary.player.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MusicLibrary.playlists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell") ?? UITableViewCell(style: .default, reuseIdentifier: "playlistCell")
        cell.textLabel?.text = MusicLibrary.playlists[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("playing playlist \(MusicLibrary.playlists[indexPath.row].name)")
        DispatchQueue.main.async {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlaylistItemTableVC") as? PlaylistItemTableViewController else
            {
                fatalError("storyboard hast to contain a PlaylistItemTableViewController with id \"PlaylistItemTableVC\"")
            }
            vc.playlistIndex = indexPath.row
            if let _ = self.navigationController {
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.present(vc, animated: true, completion: nil)
            }
        }
        
    }
    
    func didUpdate() {
        print("playing playlist \(MusicLibrary.playlists[MusicLibrary.player.currentIndex ?? 0].name)")

    }
    
}

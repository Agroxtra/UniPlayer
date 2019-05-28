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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            if self.tableView != nil {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MusicLibrary.playlists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell") ?? UITableViewCell(style: .default, reuseIdentifier: "playlistCell")
        cell.textLabel?.text = MusicLibrary.playlists[indexPath.row].name
        cell.imageView?.image = Utilities.createArtworkBorder(for: MusicLibrary.playlists[indexPath.row].image, imgView: cell.imageView)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            MusicLibrary.playlists.remove(at: indexPath.row)
            DispatchQueue.main.async {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "New Playlist", message: "Give your new playlist a name", preferredStyle: .alert)
        alertController.addTextField { (txtFld) in
            txtFld.placeholder = "Playlist Name"
        }
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            MusicLibrary.playlists.append(Playlist(name: alertController.textFields?.first?.text ?? "NO NAME"))
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    
    func didUpdate() {

    }
    
}

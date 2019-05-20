//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Martin Zörfuss on 18.05.19.
//  Copyright © 2019 Martin Zörfuss. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PlayerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.tableView.tableFooterView = UIView()
        
        self.tableView.reloadData()
        
        MusicLibrary.load()
        MusicLibrary.player.delegate = self
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MusicLibrary.library.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "musicCell")
        cell.textLabel?.text = MusicLibrary.library[indexPath.row].title
        cell.detailTextLabel?.text = MusicLibrary.library[indexPath.row].artist
        
        
        cell.imageView?.image = Utilities.createIcon(for: MusicLibrary.library[indexPath.row].getArtwork(size: CGSize(width: 200, height: 200)), imageView: cell.imageView ?? UIImageView(), background: .clear, imgFactor: 0.95, cornerRadius: 10)
        
        if let c = MusicLibrary.player.currentIndex,
            indexPath.row == c
        {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        MusicLibrary.player.playSong(index: indexPath.row)
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func didUpdate() {
        if let c = MusicLibrary.player.currentIndex,
            self.tableView != nil
        {
            DispatchQueue.main.async {
                for cell in self.tableView.visibleCells {
                    cell.accessoryType = .none
                }
                self.tableView.cellForRow(at: IndexPath(row: c, section: 0))?.accessoryType = .checkmark
            }
        }
    }
}

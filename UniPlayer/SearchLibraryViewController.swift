//
//  SearchLibraryViewController.swift
//  UniPlayer
//
//  Created by Martin Zörfuss on 22.05.19.
//  Copyright © 2019 Martin Zörfuss. All rights reserved.
//

import UIKit

class SearchLibraryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    // TODO: add support for mulitple sources
    // TODO: add search
    
    @IBOutlet weak var tableView: UITableView!
    public var playlistIndex: Int!
    
    private var isFiltered: Bool {
        get {
            return self.searchController.isActive && !(self.searchController.searchBar.text?.isEmpty ?? false)
        }
    }
    
    private var filteredContent = [Song]()
    
    private var songsToAdd = [Song]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchController.isActive = true
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search Music Library"
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFiltered {
            print("isFiltered")
            return self.filteredContent.count
        }
        
        return MusicLibrary.library.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "musicCell")
        
        let song : Song
        if self.isFiltered {
            song = self.filteredContent[indexPath.row]
        } else {
            song = MusicLibrary.library[indexPath.row]
        }
        
        cell.textLabel?.text = song.title
        cell.detailTextLabel?.text = song.artist
        
        
        cell.imageView?.image = Utilities.createIcon(for: song.getArtwork(size: CGSize(width: 200, height: 200)), imageView: cell.imageView ?? UIImageView(), background: .clear, imgFactor: 0.95, cornerRadius: 10)
        
        if let _ = self.songsToAdd.firstIndex(of: song) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song : Song
        if self.isFiltered {
            song = self.filteredContent[indexPath.row]
        } else {
            song = MusicLibrary.library[indexPath.row]
        }
        if let i = self.songsToAdd.firstIndex(of: song) {
            self.songsToAdd.remove(at: i)
            DispatchQueue.main.async {
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
            }
        } else {
            self.songsToAdd.append(song)
            DispatchQueue.main.async {
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    @IBAction func doneButtonPressed(_ sender: Any) {
        self.songsToAdd.forEach { (song) in
            MusicLibrary.playlists[self.playlistIndex].addSong(song: song)
        }
        
        DispatchQueue.main.async {
             self.navigationController?.dismiss(animated: true, completion: nil)
        }
       
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            self.filteredContent = MusicLibrary.library.filter({ (song) -> Bool in
                return song.title.lowercased().contains(searchText.lowercased())
            })
            print("filtered content: ")
            print(self.filteredContent)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

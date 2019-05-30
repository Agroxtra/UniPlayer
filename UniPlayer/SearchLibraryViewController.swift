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
    
    @IBOutlet weak var tableView: UITableView!
    public var playlistIndex: Int!
    
    private var isFiltered: Bool {
        get {
            return self.searchController.isActive && !(self.searchController.searchBar.text?.isEmpty ?? false)
        }
    }
    
    private var filteredContent = [SearchItem]()
    
    private var songsToAdd = [SearchItem]()
    
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
    
    @IBAction func testBtnPressed(_ sender: Any) {
        MusicLibrary.playlists[self.playlistIndex].addSong(youtubeId: "dQw4w9WgXcQ", completion: {
            print("ready")
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFiltered {
            return self.filteredContent.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "musicCell")
        
        if self.isFiltered {
            let searchItem : SearchItem

            searchItem = self.filteredContent[indexPath.row]
            cell.textLabel?.text = searchItem.title
            //        cell.detailTextLabel?.text = song.artist
            
            //        cell.imageView?.image = Utilities.createArtworkBorder(for: song, imgView: cell.imageView)
            
            if let _ = self.songsToAdd.firstIndex(of: searchItem) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        
    
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchItem : SearchItem
        if self.isFiltered {
            searchItem = self.filteredContent[indexPath.row]
            if let i = self.songsToAdd.firstIndex(of: searchItem) {
                self.songsToAdd.remove(at: i)
                DispatchQueue.main.async {
                    tableView.cellForRow(at: indexPath)?.accessoryType = .none
                }
            } else {
                self.songsToAdd.append(searchItem)
                DispatchQueue.main.async {
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                }
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    @IBAction func doneButtonPressed(_ sender: Any) {
//        self.songsToAdd.forEach { (song) in
//            if song
//            MusicLibrary.playlists[self.playlistIndex].addSong(song: )
//        }
        var numberOfYoutube = 1
        let completion: ()->Void = {
            numberOfYoutube -= 1
            if numberOfYoutube == 0 {
                DispatchQueue.main.async {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }
        for searchItem in songsToAdd {
            if let localSearchItem = searchItem as? LocalSearchItem {
                MusicLibrary.playlists[self.playlistIndex].addSong(song: localSearchItem.getSong())
            } else if let youtubeSearchItem = searchItem as? YoutubeSearchItem {
                MusicLibrary.playlists[self.playlistIndex].addSong(youtubeId: youtubeSearchItem.fileName, completion: completion)
                numberOfYoutube += 1
            }
        }
        
        completion()
        
        
       
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text {
            self.filteredContent = MusicLibrary.library.map({ (song) -> SearchItem in
                return LocalSearchItem(title: song.title, fileName: song.url.lastPathComponent.replacingOccurrences(of: ".mp3", with: ""))
            }).filter({ (searchItem) -> Bool in
                return (searchItem as! LocalSearchItem).conformsToSearch(for: searchText)
            })
            YoutubeSearch.search(searchString: searchText) { (items) in
                self.filteredContent.append(contentsOf: items)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            print("filtered content: ")
            print(self.filteredContent)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

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

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var musicPlayer : AVAudioPlayer? {
        didSet {
            self.musicPlayer?.delegate = self
        }
    }
    var currentIndex: Int? {
        didSet {
            if let c = self.currentIndex,
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
    var repeatType : MPRepeatType = .all
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.tableView.tableFooterView = UIView()
        self.initMusic()
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        self.initNowPlaying()
    }
    
    
    private func initMusic(){
        
        // MARK: create readme file creates directory for App
        let file = AppFile()
        _ = file.writeFile(containing: "Put all your mp3 files here and they will be recognized after relaunching the application. Then you can play them as you wish.", to: .Documents, withName: "readme.txt")
        
        MusicLibrary.library.removeAll()
        
        // MARK: read all files from Documents directory and filter them by extension mp3
        let files = AppFile().getFileUrls(directory: AppFile().documentsDirectoryURL())
        for url in files {
            if url.isFileURL && url.pathExtension == "mp3" {
                // MARK: add mp3 files to library, which is used for playing music
                MusicLibrary.library.append(Song(path: url))
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func initNowPlaying(){
        // MARK: Add callback for play/pause
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            if let p = self.musicPlayer {
                
                if p.isPlaying {
                    p.pause()
                } else {
                    p.play()
                }
                return .success
            }
            return .commandFailed
        }
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            if let p = self.musicPlayer,
                let e = event as? MPChangePlaybackPositionCommandEvent{
                p.pause()

                p.currentTime = e.positionTime
                p.play()
                return .success
            }
            return .commandFailed
        }
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = MusicLibrary.library.count > 1
        
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            if let p = self.musicPlayer {
                if p.currentTime > 5 || MusicLibrary.library[0].url == p.url {
                    p.pause()
                    p.currentTime = 0
                    p.play()
                    self.updateNowPlaying()
                    return .success
                }
            }
            if var curr = self.currentIndex {
                self.musicPlayer?.stop()
                if self.repeatType == .all || self.repeatType == .off {
                    curr -= 1
                }
                self.musicPlayer = try? AVAudioPlayer(contentsOf: MusicLibrary.library[curr].url)
                self.currentIndex = curr
                self.musicPlayer?.play()
                self.updateNowPlaying()
                return .success
            }
            return .commandFailed
        }
        
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            return self.nextSong() ? .success : .commandFailed
        }
        
        MPRemoteCommandCenter.shared().changeRepeatModeCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            
            if let e = event as? MPChangeRepeatModeCommandEvent {
                self.repeatType = e.repeatType
                return .success
            }
            return .commandFailed
        }
        
    }
    
    private func nextSong() -> Bool{
        if var curr = self.currentIndex {
            self.musicPlayer?.stop()
            
            if self.repeatType == .all {
                curr = (curr + 1)%(MusicLibrary.library.count)
            } else if self.repeatType == .off {
                if curr < MusicLibrary.library.count - 1 {
                    curr += 1
                }
            }
            self.musicPlayer = try? AVAudioPlayer(contentsOf: MusicLibrary.library[curr].url)
            self.currentIndex = curr
            self.musicPlayer?.play()
            self.updateNowPlaying()
            return true
        }
        return false
    }
    
    private func updateNowPlaying(){
        if let curr = self.currentIndex {
            let song = MusicLibrary.library[curr]
            var nowPlayingInfo = [String: Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = song.title
            nowPlayingInfo[MPMediaItemPropertyArtist] = song.artist
            
            //nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: song.artwork ?? UIImage(named: "musicnote")!)
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 200, height: 200), requestHandler: song.getArtwork(size:))
          
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.musicPlayer?.currentTime ?? 0
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.musicPlayer?.duration ?? 0
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.musicPlayer?.rate ?? 0
            
            DispatchQueue.main.async {
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MusicLibrary.library.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "musicCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "musicCell")
        cell.textLabel?.text = MusicLibrary.library[indexPath.row].title
        cell.detailTextLabel?.text = MusicLibrary.library[indexPath.row].artist
        cell.imageView?.image = MusicLibrary.library[indexPath.row].getArtwork(size: CGSize(width: 200, height: 200))
        cell.imageView?.layer.masksToBounds = true
        cell.imageView?.layer.cornerRadius = 10
        
        
        
        
        if let c = self.currentIndex,
            indexPath.row == c
        {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentIndex = indexPath.row
        let song = MusicLibrary.library[indexPath.row]
        self.musicPlayer?.stop()
        self.musicPlayer = try? AVAudioPlayer(contentsOf: song.url)
        self.musicPlayer?.play()
        self.updateNowPlaying()
        
        DispatchQueue.main.async {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        _ = self.nextSong()
    }
}

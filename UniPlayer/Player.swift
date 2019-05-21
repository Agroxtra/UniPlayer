//
//  Player.swift
//  UniPlayer
//
//  Created by Martin Zörfuss on 20.05.19.
//  Copyright © 2019 Martin Zörfuss. All rights reserved.
//

import AVFoundation
import MediaPlayer

class Player : NSObject, AVAudioPlayerDelegate {
    public var delegate: PlayerDelegate?
    private var _queue = [Song]()
    public var queue : [Song] {
        get {
            return _queue
        }
        set (newVal){
            self.musicPlayer?.stop()
            self._queue = newVal
            self.currentIndex = nil
            self.musicPlayer = nil
            self.updateNowPlaying()
        }
    }
    
    private var musicPlayer : AVAudioPlayer? {
        didSet {
            self.musicPlayer?.delegate = self
        }
    }
    public private(set) var currentIndex: Int? {
        didSet {
            self.delegate?.didUpdate()
        }
    }
    var repeatType : MPRepeatType = .all

    override init(){
        super.init()
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        self.initNowPlaying()

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
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = self._queue.count > 1
        
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            if let p = self.musicPlayer {
                if p.currentTime > 5 || self._queue[0].url == p.url {
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
                self.musicPlayer = try? AVAudioPlayer(contentsOf: self._queue[curr].url)
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
                curr = (curr + 1)%(self._queue.count)
            } else if self.repeatType == .off {
                if curr < self._queue.count - 1 {
                    curr += 1
                }
            }
            self.musicPlayer = try? AVAudioPlayer(contentsOf: self._queue[curr].url)
            self.currentIndex = curr
            print("playing next song \(self._queue[curr].title)")
            self.musicPlayer?.play()
            self.updateNowPlaying()
            return true
        }
        return false
    }
    
    private func updateNowPlaying(){
        print("updating now playing")
        MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled = self._queue.count > 1

        if let curr = self.currentIndex {
            let song = self._queue[curr]


            var nowPlayingInfo = [String: Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = song.title
            nowPlayingInfo[MPMediaItemPropertyArtist] = song.artist
            
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 200, height: 200), requestHandler: song.getArtwork(size:))
            
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.musicPlayer?.currentTime ?? 0
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.musicPlayer?.duration ?? 0
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.musicPlayer?.rate ?? 0
            DispatchQueue.main.async {
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }
    }
    
    func playSong(index: Int) {
        let song = self._queue[index]
        self.currentIndex = index
        self.musicPlayer?.stop()
        self.musicPlayer = try? AVAudioPlayer(contentsOf: song.url)
        self.musicPlayer?.play()
        
        self.updateNowPlaying()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing…")
        _ = self.nextSong()
    }
}


protocol PlayerDelegate {
    func didUpdate()
}

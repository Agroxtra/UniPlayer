//
//  MusicPlayerViewController.swift
//  MusicPlayer
//
//  Created by Martin Zörfuss on 18.05.19.
//  Copyright © 2019 Martin Zörfuss. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer


class MusicPlayerViewController : UIViewController {
    var player : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let url = Bundle.main.url(forResource: "testtrack", withExtension: "mp3")!
            //        try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            self.player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            self.setupNowPlaying()

        } catch {
            print(error)
        }
    }
    
    private func setupNowPlaying(){
//        MPRemoteCommandCenter.shared().playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
//            if let p = self.player,
//                p.rate  == 0.0
//            {
//                p.play()
//                return .success
//            }
//            return .commandFailed
//        }
//
//        MPRemoteCommandCenter.shared().pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
//            if let p = self.player,
//                p.rate  == 1.0
//            {
//                p.pause()
//                return .success
//            }
//            return .commandFailed
//        }
        
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            if let p = self.player {
                
                if p.isPlaying {
                    p.pause()
                } else {
                    p.play()
                }
                return .success
            }
            return .commandFailed
        }
        
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "testtrack.mp3"
        
        if let image = UIImage(named: "lockscreen") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.player?.currentTime ?? 0
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.player?.duration ?? 0
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player?.rate ?? 0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo

    }
}

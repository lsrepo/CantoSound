//
//  Sound.swift
//  CantoSound
//
//  Created by Pak Lau on 25/9/2020.
//

import Foundation
import AVFoundation

class Sounds {
    static var player:AVPlayer?
    static func playSounds(soundfile: URL) {
        do{
            let playerItem = AVPlayerItem.init(url: soundfile)
            player = AVPlayer.init(playerItem: playerItem)
            player?.play()
        }catch {
            print("Error")
        }
    }
}

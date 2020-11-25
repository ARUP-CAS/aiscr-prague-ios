//
//  VideoCard.swift
//  Archeologie
//
//  Created by Matěj Novák on 14/09/2020.
//  Copyright © 2020 Matěj Novák. All rights reserved.
//

import UIKit
import YouTubePlayer

class VideoCard:UIView {
    @IBOutlet weak var label:UILabel!
    @IBOutlet weak var videoView:UIView!
    var player:YouTubePlayerView?
    var video:Video! {
        didSet {
            if let url = try? video.urlVideo?.asURL() {
                let player = YouTubePlayerView()
                videoView.addSubview(player)
//                player.leadingAnchor.constraint(equalTo: videoView.leadingAnchor).isActive = true
//                player.trailingAnchor.constraint(equalTo: videoView.trailingAnchor).isActive = true
//                player.topAnchor.constraint(equalTo: videoView.topAnchor).isActive = true
//                player.bottomAnchor.constraint(equalTo: videoView.bottomAnchor).isActive = true
                
                player.loadVideoURL(url)
                self.player = player
                player.clipsToBounds = false
            }
            label.text = video.text
        }
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.player?.frame = videoView.bounds
    }
}

//
//  PlayerViewController.swift
//  MyNetflix
//
//  Created by joonwon lee on 2020/04/01.
//  Copyright © 2020 com.joonwon. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    let player = AVPlayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playerView.player = player
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.player.play()
    }
    @IBAction func togglePlaybutton(_ sender: Any) {
        
        if player.isPlaying{
            player.pause()
        }else{
            player.play()
        }
        
        self.playButton.isSelected = !self.playButton.isSelected
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .landscapeRight
    }
    
    @IBAction func closeButtonTapped(_ sender: Any){
        reset()
        self.presentingViewController?.dismiss(animated: false)
    }
    
    func reset() {
        player.pause()
        player.replaceCurrentItem(with: nil)
    }
}

extension AVPlayer{
    var isPlaying: Bool{
        guard self.currentItem != nil else {
            return false
        }
        
        return self.rate != 0
    }
}

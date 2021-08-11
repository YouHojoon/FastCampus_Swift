//
//  TrackCollectionViewCell.swift
//  AppleMusicStApp
//
//  Created by joonwon lee on 2020/01/12.
//  Copyright © 2020 com.joonwon. All rights reserved.
//

import UIKit

class TrackCollecionViewCell: UICollectionViewCell {
    @IBOutlet weak var trackThumbnail: UIImageView!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackArtist: UILabel!
    
    //앱에 올라올 때
    override func awakeFromNib() {
        super.awakeFromNib()
        trackThumbnail.layer.cornerRadius = 4
        trackArtist.textColor = UIColor.systemGray2
        self.trackTitle.textColor = UIColor.white
        self.backgroundColor = UIColor.black
    }
    
    func updateUI(item: Track?) {
        // TODO: 곡정보 표시하기
        self.trackTitle?.text = item?.title
        self.trackArtist?.text = item?.artist
        self.trackThumbnail?.image = item?.artwork
    }
}

//
//  PodcastCell.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 2. 27..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit
import SDWebImage

final class PodcastCell: UITableViewCell {
    @IBOutlet weak var podcastImageView: UIImageView! {
        didSet {
            podcastImageView.sd_setShowActivityIndicatorView(true)
            podcastImageView.sd_setIndicatorStyle(.gray)
        }
    }
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!

    var podcastViewModel: PodcastViewModel? {
        didSet {
            guard let vm = podcastViewModel else { return }
            trackNameLabel.text = vm.title
            artistNameLabel.text = vm.artist
            episodeCountLabel.text = vm.episodeString

            podcastImageView.sd_setImage(with: vm.artworkUrl)
        }
    }

}

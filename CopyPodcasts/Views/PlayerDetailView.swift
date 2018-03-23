//
//  PlayerDetailView.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 3. 15..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit

class PlayerDetailView: UIView {
	
	var episode: Episode! {
		didSet {
			titleLabel.text = episode.title
			authorLabel.text = episode.author
			let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
			episodeImageView.sd_setImage(with: url)
		}
	}
	
	@IBAction func handleDismiss(_ sender: Any) {
		self.removeFromSuperview()
	}
	
	@IBOutlet weak var episodeImageView: UIImageView!
	
	
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.numberOfLines = 2
		}
	}
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var playPauseButton: UIButton!
}

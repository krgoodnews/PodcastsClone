//
//  PlayerDetailView.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 3. 15..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit
import AVKit

class PlayerDetailView: UIView {
	
	var episode: Episode! {
		didSet {
			titleLabel.text = episode.title
			authorLabel.text = episode.author
			
			playEpisode()
			
			let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
			episodeImageView.sd_setImage(with: url)
		}
	}
	
	fileprivate func playEpisode() {
		print("Trying to play episode at url:", episode.streamUrl)
		guard let url = URL(string: episode.streamUrl) else { return }
		let playerItem = AVPlayerItem(url: url)
		player.replaceCurrentItem(with: playerItem)
		player.play()
	}
	
	let player: AVPlayer = {
		let avPlayer = AVPlayer()
		avPlayer.automaticallyWaitsToMinimizeStalling = false // 다운로드가 전부 완료되지 않아도 재생 가능하면 바로 재생 가능
		return avPlayer
	}()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		let time = CMTimeMake(1, 3)
		let times = [NSValue(time: time)]
		player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
			print("Episode started playing")
			self.enlargeEpisodeImageView()
		}
	}
	
	
	// MARK: - IBActions & Outlets
	
	@IBAction func handleDismiss(_ sender: Any) {
		self.removeFromSuperview()
	}
	
	fileprivate func enlargeEpisodeImageView() {
		UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.episodeImageView.transform = .identity
		})
	}
	
	fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
	
	fileprivate func shrinkEpisodeImageView() {
		UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.episodeImageView.transform = self.shrunkenTransform
		})
	}
	
	
	@IBOutlet weak var episodeImageView: UIImageView! {
		didSet {
			episodeImageView.layer.cornerRadius = 5
			episodeImageView.clipsToBounds = true
			episodeImageView.transform = shrunkenTransform
		}
	}
	
	
	@IBOutlet weak var titleLabel: UILabel! {
		didSet {
			titleLabel.numberOfLines = 2
		}
	}
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var playPauseButton: UIButton! {
		didSet {
			playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
			playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
		}
	}
	
	@objc func didTapPlayPause() {
		print("Trying to play and pause")
		if player.timeControlStatus == .paused {
			player.play()
			playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
			enlargeEpisodeImageView()
		} else {
			player.pause()
			playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			shrinkEpisodeImageView()
		}
	}
}

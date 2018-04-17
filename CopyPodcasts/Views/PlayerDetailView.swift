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
			miniTitleLabel.text = episode.title
			titleLabel.text = episode.title
			authorLabel.text = episode.author
			
			playEpisode()
			
			let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
			episodeImageView.sd_setImage(with: url)
			miniEpisodeImageView.sd_setImage(with: url)
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
	
	
	// 현재 시간 표시하기
	fileprivate func observePlayerCurrentTime() {
		let interval = CMTimeMake(1, 2)
		player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
			
			self?.currentTimeLabel.text = time.toDisplayString()
			
			let durationTime = self?.player.currentItem?.duration
			
			self?.durationLabel.text = durationTime?.toDisplayString()
			
			self?.updateCurrentTimeSlider()
		}
	}
	
	fileprivate func updateCurrentTimeSlider() {
		let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
		let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(1, 1))
		let percentage = currentTimeSeconds / durationSeconds
		
		self.currentTimeSlider.value = Float(percentage)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapMaximize)))
		addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
		
		observePlayerCurrentTime()
		
		let time = CMTimeMake(1, 3)
		let times = [NSValue(time: time)]
		
		// player has a reference to self
		// self has a reference to player
		player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
			print("Episode started playing")
			self?.enlargeEpisodeImageView()
		}
	}
	
	@objc private func handlePan(gesture: UIPanGestureRecognizer) {
		
		if gesture.state == .began {
			print("Began")
		} else if gesture.state == .changed {
			
			let translation = gesture.translation(in: self.superview)
			self.transform = CGAffineTransform(translationX: 0, y: translation.y)
			
			self.miniPlayerView.alpha = 1 + translation.y / 200
			self.maximizedStackView.alpha = -translation.y / 200
			
			print(translation.y)
		} else if gesture.state == .ended {
			print("Ended")
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
				self.transform = .identity
				self.miniPlayerView.alpha = 1
				self.maximizedStackView.alpha = 0
			})
		}
	}
	
	@objc private func didTapMaximize() {
		let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
		mainTabBarController?.maximizePlayerDetails(nil)
		print("Tapping to maximize")
	}
	
	static func initFromNib() -> PlayerDetailView {
		return Bundle.main.loadNibNamed("PlayerDetailView", owner: self, options: nil)?.first as! PlayerDetailView
	}
	
	deinit {
		print("PlayerDetailsView memory being reclaimed...")
	}
	
	
	// MARK: - IBActions & Outlets
	
	
	@IBOutlet weak var miniEpisodeImageView: UIImageView!
	@IBOutlet weak var miniTitleLabel: UILabel!
	@IBOutlet weak var miniPlayPauseButton: UIButton! {
		didSet {
			miniPlayPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
		}
	}
	@IBOutlet weak var miniFastForwardButton: UIButton!
	
	
	@IBOutlet weak var miniPlayerView: UIView!
	@IBOutlet weak var maximizedStackView: UIStackView!
	
	
	@IBOutlet weak var currentTimeSlider: UISlider!
	@IBOutlet weak var currentTimeLabel: UILabel!
	@IBOutlet weak var durationLabel: UILabel!

	
	@IBAction func handleDismiss(_ sender: Any) {
//		self.removeFromSuperview()
		let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
		mainTabBarController?.minimizePlayerDetails()
	}
	
	
	@IBAction func handleCurrentTimeSliderChange(_ sender: UISlider) {
		print("Slider Value:", currentTimeSlider.value)
		let percentage = Float64(currentTimeSlider.value)
		
		guard let duration = player.currentItem?.duration else { return }
		
		let durationInSeconds = CMTimeGetSeconds(duration)
		let seekTimeInSeconds = percentage * durationInSeconds
		
		let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, 1)
		
		player.seek(to: seekTime)
	}
	
	@IBAction func didTapRewind(_ sender: UIButton) {
		seekToCurrentTime(-15)
	}
	
	@IBAction func didTapFastForward(_ sender: UIButton) {
		seekToCurrentTime(15)
	}
	
	// delta초만큼 이동
	fileprivate func seekToCurrentTime(_ delta: Int64) {
		let fifteenSeconds = CMTimeMake(delta, 1)
		let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
		player.seek(to: seekTime)
	}
	
	@IBAction func handleVolumeChange(_ sender: UISlider) {
		player.volume = sender.value
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
			miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
			enlargeEpisodeImageView()
		} else {
			player.pause()
			playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			shrinkEpisodeImageView()
		}
	}
}

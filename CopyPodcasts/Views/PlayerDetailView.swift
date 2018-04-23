//
//  PlayerDetailView.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 3. 15..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class PlayerDetailView: UIView {
	
	var episode: Episode! {
		didSet {
			miniTitleLabel.text = episode.title
			titleLabel.text = episode.title
			authorLabel.text = episode.author
			
			setupNowPlayingInfo()
			
			playEpisode()
			
			let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
			episodeImageView.sd_setImage(with: url)
			
			
			miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
				
				guard let image = image else { return }
				
				// LockScreen artwork setup code
				var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
				
				// some modifications here
				let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> UIImage in
					return image
				})
				nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
				
				MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
			}
		}
	}
	
	
	// setupNowPlayingInfo on LockScreen
	fileprivate func setupNowPlayingInfo() {
		var nowPlayingInfo = [String: Any]()
		
		nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
		nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
		
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
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
			
			self?.setupLockscreenCurrentTime()
			
			self?.updateCurrentTimeSlider()
		}
	}
	
	fileprivate func setupLockscreenCurrentTime() {
		var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo

		// modifications
		guard let currentItem = player.currentItem else { return }
		let durationInSeconds = CMTimeGetSeconds(currentItem.duration)
		
		let elapsedTime = CMTimeGetSeconds(player.currentTime())
		
		nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
		nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
		
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
	}
	
	fileprivate func updateCurrentTimeSlider() {
		let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
		let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(1, 1))
		let percentage = currentTimeSeconds / durationSeconds
		
		self.currentTimeSlider.value = Float(percentage)
	}
	
	var panGesture: UIPanGestureRecognizer!
	
	fileprivate func setupGestures() {
		addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapMaximize)))
		panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
		miniPlayerView.addGestureRecognizer(panGesture)

		maximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
	}
	
	@objc private func handleDismissalPan(gesture: UIPanGestureRecognizer) {
		
		
		if gesture.state == .changed {
			let translation = gesture.translation(in: superview)
			maximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
		} else if gesture.state == .ended {

			let translation = gesture.translation(in: superview)
			let velocity = gesture.velocity(in: superview)
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
				self.maximizedStackView.transform = .identity
				
				if translation.y > 200 || velocity.y >  500 {
					UIApplication.mainTabBarController()?.minimizePlayerDetails()
				}
			})
		}
		
	}
	override func awakeFromNib() {
		super.awakeFromNib()
		
		
		// for Background Audio
		setupRemoteControl()
		setupAudioSession()
		
		
		
		setupGestures()
		
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
	
	
	
	fileprivate func setupRemoteControl() {
		// 제어센터에서 플레이어를 컨트롤 할 수 있게 도와준다.
		UIApplication.shared.beginReceivingRemoteControlEvents()
		
		let commandCenter = MPRemoteCommandCenter.shared()
		commandCenter.playCommand.isEnabled = true
		commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
			
			self.player.play()
			self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
			self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
			return .success
		}
		
		commandCenter.pauseCommand.isEnabled = true
		commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
			
			self.player.pause()
			self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			return .success
		}
		
		commandCenter.togglePlayPauseCommand.isEnabled = true // for earphone
		commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
			
			self.didTapPlayPause()
			
			return .success
		}
		
	}
	
	fileprivate func setupAudioSession() {
		do {
			try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
			try AVAudioSession.sharedInstance().setActive(true)
		} catch let sessionErr {
			print("Failed to activate session:", sessionErr)
		}
	}
	
	
	@objc private func didTapMaximize() {
		UIApplication.mainTabBarController()?.maximizePlayerDetails(nil)
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
		UIApplication.mainTabBarController()?.minimizePlayerDetails()
		
		panGesture.isEnabled = true
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

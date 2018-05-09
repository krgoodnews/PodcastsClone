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
			
			setupAudioSession()
			
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
		if episode.fileUrl != nil {
			self.playEpisodeUsingFileUrl()
			
		} else {
			print("Trying to play episode at url:", episode.streamUrl)
			guard let url = URL(string: episode.streamUrl) else { return }
			let playerItem = AVPlayerItem(url: url)
			player.replaceCurrentItem(with: playerItem)
			player.play()
		}
	}
	
	fileprivate func playEpisodeUsingFileUrl() {
		print("Attempt to play episode with file url:", episode.fileUrl ?? "")
		
		// let's figure out the file name for our episode file url
		guard let fileURL = URL(string: episode.fileUrl ?? "") else { return }
		let fileName = fileURL.lastPathComponent
		
		
		guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
		trueLocation.appendPathComponent(fileName)
		
		print("True Location of episode:", trueLocation.absoluteString)
		
		let playerItem = AVPlayerItem(url: trueLocation)
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

		backgroundMaximizedStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
	}
	
	@objc private func handleDismissalPan(gesture: UIPanGestureRecognizer) {
		
		
		if gesture.state == .changed {
			let translation = gesture.translation(in: superview)
			backgroundMaximizedStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
		} else if gesture.state == .ended {

			let translation = gesture.translation(in: superview)
			let velocity = gesture.velocity(in: superview)
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
				self.backgroundMaximizedStackView.transform = .identity
				
				if translation.y > 200 || velocity.y >  500 {
					UIApplication.mainTabBarController()?.minimizePlayerDetails()
				}
			})
		}
	}
	fileprivate func observeBoundaryTime() {
		let time = CMTimeMake(1, 3)
		let times = [NSValue(time: time)]
		
		// player has a reference to self
		// self has a reference to player
		player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
			print("Episode started playing")
			self?.enlargeEpisodeImageView()
			self?.setupLockscreenDuration()
		}
	}
	
	fileprivate func setupLockscreenDuration() {
		guard let duration = player.currentItem?.duration else { return }
		let durationSeconds = CMTimeGetSeconds(duration)
		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationSeconds
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setupUI()
		
		// for Background Audio
		setupRemoteControl()
		
		setupGestures()
		
		setupInterruptionObserver()
		
		observePlayerCurrentTime()
		
		observeBoundaryTime()
	}
	
	fileprivate func setupUI() {
		
	}
	
	
	// 전화가 오거나 기타 오디오가 중지되어야 할 다른 작업이 존재할 경우 실행되는 이벤트
	fileprivate func setupInterruptionObserver() {
		NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: .AVAudioSessionInterruption, object: nil)
	}
	
	@objc fileprivate func handleInterruption(notification: Notification) {
		print("Interruption observed")
		
		guard let userInfo = notification.userInfo else { return }
		
		guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }
		
		if type == AVAudioSessionInterruptionType.began.rawValue {
			// 전화가 왔을 때
			print("Interruption began")
			playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			
		} else {
			// 전화가 끊겼을 때
			print("Interruption ended..")
			
			guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
			
			
			// 왜인지는 모르겠는데 조건문으로 걸러줘야 오류가 생기지 않음
			if options == AVAudioSessionInterruptionOptions.shouldResume.rawValue {
				player.play()
				playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
				miniPlayPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
			}
		}
		
//		AVAudioSessionInterruptionType
		
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
			
			self.setupElapsedTime(playbackRate: 1)
			
			return .success
		}
		
		commandCenter.pauseCommand.isEnabled = true
		commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
			
			self.player.pause()
			self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			self.miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			
			self.setupElapsedTime(playbackRate: 0)
			
			
			return .success
		}
		
		commandCenter.togglePlayPauseCommand.isEnabled = true // for earphone
		commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
			
			self.didTapPlayPause()
			
			return .success
		}
		
		// next & previous track command
		commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
		commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePrevTrack))
	}
	
	var playlistEpisodes = [Episode]()
	
	@objc fileprivate func handleNextTrack() {
		
		if playlistEpisodes.count == 0 {
			return
		}
		
		
		let currentEpisodeIndex = playlistEpisodes.index { (ep) -> Bool in
			return self.episode.title == ep.title && self.episode.author == ep.author
		}
		
		guard let index = currentEpisodeIndex else { return }
		
		let nextEpisode: Episode
		if index == playlistEpisodes.count - 1 {
			nextEpisode = playlistEpisodes[0]
		} else {
			nextEpisode = playlistEpisodes[index + 1]
		}
		
		
		self.episode = nextEpisode
	}
	@objc fileprivate func handlePrevTrack() {
		
		if playlistEpisodes.count == 0 {
			return
		}
		
		
		let currentEpisodeIndex = playlistEpisodes.index { (ep) -> Bool in
			return self.episode.title == ep.title && self.episode.author == ep.author
		}
		
		guard let index = currentEpisodeIndex else { return }
		
		let prevEpisode: Episode
		if index == 0 {
			prevEpisode = playlistEpisodes[playlistEpisodes.count - 1]
		} else {
			prevEpisode = playlistEpisodes[index - 1]
		}
		
		
		self.episode = prevEpisode
	}
	
	fileprivate func setupElapsedTime(playbackRate: Float) {
		let elapsedTime = CMTimeGetSeconds(player.currentTime())
		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
		
		// 백그라운드 재생창 컨트롤시 시간 싱크를 위해 집어넣음
		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate

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
		UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: nil)
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
	
	@IBOutlet weak var backgroundMaximizedStackView: UIView!
	
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
		
		// setup Lockscreen info
		MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
		
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
			self.setupElapsedTime(playbackRate: 1)
		} else {
			player.pause()
			playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			miniPlayPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
			shrinkEpisodeImageView()
			self.setupElapsedTime(playbackRate: 0)
		}
	}
}

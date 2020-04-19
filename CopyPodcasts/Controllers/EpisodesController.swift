//
//  EpisodesController.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 3. 10..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
	
	var podcastViewModel: PodcastViewModel? {
		didSet {
			navigationItem.title = podcastViewModel?.title
			fetchEpisodes()
		}
	}
	
	fileprivate func fetchEpisodes() {
		let podcast = podcastViewModel?.podcast
		print("Looking for episodes at feed url:", podcast?.feedURLString ?? "")
		
		guard let feedUrl = podcast?.feedURLString else { return }
		
		APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
			self.episodes = episodes
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	
	fileprivate let cellID = "cellID"
	
	var episodes: [Episode] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupTableView()
		setupNavigationBarButtons()
	}
	
	// MARK: - setup Work
	
	fileprivate func setupNavigationBarButtons() {
		// let's check if we have already saved this podcast as fav
		let savedPodcasts = UserDefaults.standard.savedPodcastViewModels()
		
		let hasFavorited = savedPodcasts.firstIndex(where: { $0.title == self.podcastViewModel?.title && $0.artist == self.podcastViewModel?.artist }) != nil
		
		if hasFavorited {
			// setting up heart Icon
			navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
		} else {
			navigationItem.rightBarButtonItems = [
				UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite)),
//				UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSavedPodcasts)
			]
		}
		
		
	}
	
	@objc private func handleFetchSavedPodcasts() {
		print("Fetching saved Podcasts from UserDefaults")
		
		// how to retrieve our Podcast object from UserDefaults
		let savedPodcasts = UserDefaults.standard.savedPodcastViewModels()
		
		savedPodcasts.forEach({ (p) in
			print(p.title)
		})
	}
	
	@objc private func handleSaveFavorite() {
		guard let podcast = self.podcastViewModel else { return }
		
		// 1. Transform podcast into data
		var listOfPodcasts = UserDefaults.standard.savedPodcastViewModels()
		listOfPodcasts.append(podcast)

        do {
            let encoded = try PropertyListEncoder().encode(listOfPodcasts)
            let data = NSKeyedArchiver.archivedData(withRootObject: encoded)
            UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
        } catch {
            print("Save Failed")
        }
		
		showBadgeHighlight()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "heart"), style: .plain, target: nil, action: nil)
		
		print("Saving info into UserDefaults")
	}
	
	fileprivate func showBadgeHighlight() {
		UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = "New"
	}
	
	fileprivate func setupTableView() {
		let nib = UINib(nibName: "EpisodeCell", bundle: nil)
		tableView.register(nib, forCellReuseIdentifier: cellID)
		tableView.tableFooterView = UIView()
	}
	
	// MARK: - UITableView
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { (_, _) in
			print("Downloading episode into UserDefaults")
			let episode = self.episodes[indexPath.row]
			UserDefaults.standard.downloadEpisode(episode: episode)
			
			// download the podcast episode using Alamofire
			APIService.shared.downloadEpisode(episode: episode)
		}
		
		return [downloadAction]
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let episode = self.episodes[indexPath.row]

		UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
		
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.episodes.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! EpisodeCell
		let episode = self.episodes[indexPath.row]
		
		cell.episode = episode
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 134
	}
	
	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
		activityIndicatorView.color = .darkGray
		activityIndicatorView.startAnimating()
		return activityIndicatorView
	}
	
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return episodes.isEmpty ? 200 : 0
	}
}

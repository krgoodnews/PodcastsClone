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
	
	var podcast: Podcast? {
		didSet {
			navigationItem.title = podcast?.trackName
			
			fetchEpisodes()
		}
	}
	
	fileprivate func fetchEpisodes() {
		print("Looking for episodes at feed url:", podcast?.feedUrl ?? "")
		
		guard let feedUrl = podcast?.feedUrl else { return }
		
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
	}
	
	// MARK: - setup Work
	
	fileprivate func setupTableView() {
		let nib = UINib(nibName: "EpisodeCell", bundle: nil)
		tableView.register(nib, forCellReuseIdentifier: cellID)
		tableView.tableFooterView = UIView()
	}
	
	// MARK: - UITableView
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let episode = self.episodes[indexPath.row]
		print("Trying to play episode:", episode.title)
		
		let window = UIApplication.shared.keyWindow
		
		let playerDetailsView = Bundle.main.loadNibNamed("PlayerDetailView", owner: self, options: nil)?.first as! PlayerDetailView
		playerDetailsView.episode = episode
		
		playerDetailsView.frame = self.view.frame
		window?.addSubview(playerDetailsView)
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
}

//
//  DownloadsController.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 5. 7..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit

class DownloadsController: UITableViewController {
	
	fileprivate let cellID = "cellID"
	
	var episodes = UserDefaults.standard.downloadedEpisodes()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupTableView()
	}
	
	fileprivate func refreshEpisodes() {
		episodes = UserDefaults.standard.downloadedEpisodes()
		tableView.reloadData()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		refreshEpisodes()
	}
	
	// MARK: - Setup
	
	fileprivate func setupTableView()   {
		let nib = UINib(nibName: "EpisodeCell", bundle: nil)
		tableView.register(nib, forCellReuseIdentifier: cellID)
	}
	
	
	// MARK: - UITableView
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		print("Launch episode player")
		let episode = self.episodes[indexPath.row]
		
		
		
		UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
	}
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
			UserDefaults.standard.deleteDownloadedEpisode(at: indexPath.row)
			self.episodes = UserDefaults.standard.downloadedEpisodes()
			self.tableView.deleteRows(at: [indexPath], with: .automatic)
		}
		
		return [deleteAction]
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return episodes.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! EpisodeCell
		
		cell.episode = self.episodes[indexPath.row]
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 134
	}
	
}

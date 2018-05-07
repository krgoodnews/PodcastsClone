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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		episodes = UserDefaults.standard.downloadedEpisodes()
		tableView.reloadData()
	}
	
	// MARK: - Setup
	
	fileprivate func setupTableView() {
		let nib = UINib(nibName: "EpisodeCell", bundle: nil)
		tableView.register(nib, forCellReuseIdentifier: cellID)
	}
	
	
	// MARK: - UITableView
	
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

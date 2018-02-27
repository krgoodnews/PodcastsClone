//
//  PodcastsSearchController.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 2. 27..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit

class PodcastsSearchController: UITableViewController {
	
	let podcasts = [
		Podcast(name: "Perfect day", artistName: "Guinnesswift"),
		Podcast(name: "Lets build that app", artistName: "bVoong"),
		Podcast(name: "I'm so starving", artistName: "Yunsu guk")
	]
	
	let cellID = "podcastCellID"
	
	// lets implement a UISearchController
	let searchController = UISearchController(searchResultsController: nil)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupSearchBar()
		setupTableView()
	}
	
	// MARK: - Setup Work
	
	fileprivate func setupSearchBar() {
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		searchController.dimsBackgroundDuringPresentation = false
		searchController.searchBar.delegate = self
	}
	
	fileprivate func setupTableView() {
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
	}
	
	// MARK: - TableView
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return podcasts.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
		
		let podcast = self.podcasts[indexPath.row]
		cell.textLabel?.text = "\(podcast.name)\n\(podcast.artistName)"
		cell.textLabel?.numberOfLines = -1
		cell.imageView?.image = #imageLiteral(resourceName: "appicon")
		
		return cell
	}
}

extension PodcastsSearchController: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		print(searchText)
		// later implement alamofire to search iTunes API
	}
	
}

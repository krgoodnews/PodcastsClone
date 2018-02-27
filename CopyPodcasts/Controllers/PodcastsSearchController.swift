//
//  PodcastsSearchController.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 2. 27..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit
import Alamofire

class PodcastsSearchController: UITableViewController {
	
	var podcasts: [Podcast] = [] {
		didSet {
			self.tableView.reloadData()
		}
	}
	
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

		tableView.tableFooterView = UIView()
		let nib = UINib(nibName: "PodcastCell", bundle: nil)
		tableView.register(nib, forCellReuseIdentifier: cellID)
	}
	
	// MARK: - TableView
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return podcasts.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PodcastCell
		
		let podcast = self.podcasts[indexPath.row]
		
		cell.podcast = podcast
		
//		cell.textLabel?.text = "\(podcast.trackName ?? "-")\n\(podcast.artistName ?? "-")"
//		cell.textLabel?.numberOfLines = -1
//		cell.imageView?.image = #imageLiteral(resourceName: "appicon")
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 132
	}
	
	
	// header & footer
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let label = UILabel()
		label.text = "Please enter a Search Term"
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
		return label
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return self.podcasts.count == 0 ? 250 : 0
	}
}

extension PodcastsSearchController: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		APIService.shared.fetchPodcasts(searchText: searchText) { (podcasts) in
			self.podcasts = podcasts
		}
	}
	
}

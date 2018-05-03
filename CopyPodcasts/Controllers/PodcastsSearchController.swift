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
	
	var timer: Timer?
	
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
		
		searchBar(searchController.searchBar, textDidChange: "coding") // for testing
	}
	
	// MARK: - Setup Work
	
	fileprivate func setupSearchBar() {
		self.definesPresentationContext = true
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
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedPodcast = podcasts[indexPath.row]
		
		let destVC = EpisodesController()
		destVC.podcast = selectedPodcast
		navigationController?.pushViewController(destVC, animated: true)
	}
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
		
		// terary operator
		return self.podcasts.count > 0 ? 0 : 250
	}
}

extension PodcastsSearchController: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
		timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
			APIService.shared.fetchPodcasts(searchText: searchText) { (podcasts) in
				self.podcasts = podcasts
			}
		})
		
	}
	
}

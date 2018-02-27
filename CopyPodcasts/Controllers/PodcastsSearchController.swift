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
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
	}
	
	// MARK: - TableView
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return podcasts.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
		
		let podcast = self.podcasts[indexPath.row]
		cell.textLabel?.text = "\(podcast.trackName ?? "-")\n\(podcast.artistName ?? "-")"
		cell.textLabel?.numberOfLines = -1
		cell.imageView?.image = #imageLiteral(resourceName: "appicon")
		
		return cell
	}
	
	struct SearchResults: Decodable {
		let resultCount: Int
		let results: [Podcast]
	}
}

extension PodcastsSearchController: UISearchBarDelegate {
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		print(searchText)
		
//		let url = "https://itunes.apple.com/search?term=\(searchText)"
		
		let url = "https://itunes.apple.com/search"
		let parameters: Parameters = [
			"term": searchText,
			"media": "podcast"
		]
		
		Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
			if let err = dataResponse.error {
				print("Failed to contact yahoo", err)
				return
			}
			
			guard let data = dataResponse.data else { return }
			
			do {
				let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
		
				self.podcasts = searchResult.results
			} catch let decodeErr {
				print("Failed to decode:", decodeErr)
			}
			
			
		}
	}
	
}

//
//  APIService.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 2. 27..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

class APIService {
	
	let baseiTunesSearchURL = "https://itunes.apple.com/search"
	
	// singleton
	static let shared = APIService()
	
	func fetchEpisodes(feedUrl: String, completion: @escaping ([Episode]) -> ()) {
		let secureFeedUrl = feedUrl.contains("https") ? feedUrl : feedUrl.replacingOccurrences(of: "http", with: "https")
		
		guard let url = URL(string: secureFeedUrl) else { return }
		let parser = FeedParser(URL: url)
		parser?.parseAsync(result: { (result) in
			print("Successfully parse feed:", result.isSuccess)
			
			if let err = result.error {
				print("Failed to parse XML feed:", err)
			}
			
			guard let feed = result.rssFeed else { return }
			
			completion(feed.toEpisodes())
			
		})
	}
	
	func fetchMusic() {
		
	}
	
	func fetchPodcasts(searchText: String, completion: @escaping ([Podcast]) -> ()) {
		print("Serching for podcasts...")
		
		let parameters: Parameters = [
			"term": searchText,
			"media": "podcast"
		]
		
		Alamofire.request(baseiTunesSearchURL, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
			if let err = dataResponse.error {
				print("Failed to contact yahoo", err)
				return
			}
			
			guard let data = dataResponse.data else { return }
			
			do {
				let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
				
				completion(searchResult.results)
			} catch let decodeErr {
				print("Failed to decode:", decodeErr)
			}
			
			
		}
	}
	
	struct SearchResults: Decodable {
		let resultCount: Int
		let results: [Podcast]
	}
}

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

extension Notification.Name {
	
	static let downloadProgress = NSNotification.Name("downloadProgress")
	static let downloadComplete = NSNotification.Name("downloadComplete")
	
}

class APIService {
	
	typealias EpisodeDownloadCompleteTuple = (fileUrl: String, episodeTitle: String)
	
	let baseiTunesSearchURL = "https://itunes.apple.com/search"
	
	// singleton
	static let shared = APIService()
	
	
	
	func downloadEpisode(episode: Episode) {
		print("Downloading episode using Alamofire at streamUrl:", episode.streamUrl)
		
		let downloadsRequest = DownloadRequest.suggestedDownloadDestination()
		
		Alamofire.download(episode.streamUrl, to: downloadsRequest).downloadProgress { (progress) in
			
			print(progress.fractionCompleted)
			
			// I want to notify DownloadsController about my download progress somehow?
			
			NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title, "progress": progress.fractionCompleted])
			
			}.response { (resp) in
				print(resp.destinationURL?.absoluteString ?? "")
				
				let episodeDownloadComplete = EpisodeDownloadCompleteTuple(resp.destinationURL?.absoluteString ?? "", episode.title)
				
				NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete, userInfo: nil)
				
				// I want to update UserDefaults downloaded episodes with this temp file somehow
				var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
				guard let index = downloadedEpisodes.firstIndex(where: { $0.title == episode.title && $0.author == episode.author }) else { return }
				
				downloadedEpisodes[index].fileUrl = resp.destinationURL?.absoluteString ?? ""
				
				do {
					let data = try JSONEncoder().encode(downloadedEpisodes)
					UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)

				} catch let err {
					print("Failed to encode downloaded episodes with file url update:", err)
				}
				
		}
		
			
		
	}
	
	
	
	
	func fetchEpisodes(feedUrl: String, completion: @escaping ([Episode]) -> ()) {
		let secureFeedUrl = feedUrl.contains("https") ? feedUrl : feedUrl.replacingOccurrences(of: "http", with: "https")
		
		guard let url = URL(string: secureFeedUrl) else { return }
		
		DispatchQueue.global(qos: .background).async {
			print("Before parser")
			let parser = FeedParser(URL: url)
			print("After parser")
			
			parser.parseAsync(result: { (result) in
				print("Successfully parse feed:", result.isSuccess)
				
				if let err = result.error {
					print("Failed to parse XML feed:", err)
				}
				
				guard let feed = result.rssFeed else { return }
				
				completion(feed.toEpisodes())
				
			})
		}
	}
	
	func fetchMusic() {
		
	}
	
	func fetchPodcasts(searchText: String, completion: @escaping ([Podcast]) -> ()) {
		print("Searching for podcasts...\(searchText)")
		
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

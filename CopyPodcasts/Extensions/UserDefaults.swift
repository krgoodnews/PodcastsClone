//
//  UserDefaults.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 5. 4..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import Foundation

extension UserDefaults {
	
	static let favoritedPodcastKey = "favoritedPodcastKey"
	
	func savedPodcasts() -> [Podcast] {
		
		guard let savedPodcastsData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return [] }
		
		let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastsData) as? [Podcast] ?? [Podcast]()
		
		return savedPodcasts
	}
}

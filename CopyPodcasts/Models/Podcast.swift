//
//  Podcast.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 2. 27..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import Foundation

class Podcast: NSObject, Decodable, NSCoding {
	
	func encode(with aCoder: NSCoder) {
		print("Trying to transform Podcast into Data")
		aCoder.encode(trackName, forKey: "trackNameKey")
		aCoder.encode(artistName, forKey: "artistNameKey")
		aCoder.encode(artworkUrl600, forKey: "artworkKey")
		aCoder.encode(feedUrl, forKey: "feedKey")
	}
	
	required init?(coder aDecoder: NSCoder) {
		print("Trying to turn Data into Podcast")
		self.trackName = aDecoder.decodeObject(forKey: "trackNameKey") as? String
		self.artistName = aDecoder.decodeObject(forKey: "artistNameKey") as? String
		self.artworkUrl600 = aDecoder.decodeObject(forKey: "artworkKey") as? String
		self.feedUrl = aDecoder.decodeObject(forKey: "feedKey") as? String
		
	}
	
	var trackName: String?
	var artistName: String?
	var artworkUrl600: String?
	var trackCount: Int?
	var feedUrl: String?
}


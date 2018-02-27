//
//  Podcast.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 2. 27..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import Foundation

struct Podcast: Decodable {
	let trackName: String?
	let artistName: String?
	var artworkUrl600: String?
	var trackCount: Int?
	var feedUrl: String?
}


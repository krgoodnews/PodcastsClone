//
//  Podcast.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 2. 27..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import Foundation

final class Podcast: Codable {
	var trackName: String?
	var artistName: String?
	var artworkURL600: String?
	var trackCount: Int?
	var feedURLString: String?

    enum CodingKeys: String, CodingKey {
        case trackName
        case artistName
        case artworkURL600 = "artworkUrl600"
        case feedURLString = "feedUrl"
    }
}

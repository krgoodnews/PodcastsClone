//
//  RSSFeed+.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 3. 11..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import Foundation
import FeedKit

extension RSSFeed {

    func toEpisodes() -> [Episode] {

        let imageUrl = iTunes?.iTunesImage?.attributes?.href

        var episodes = [Episode]()
        items?.forEach({ (feedItem) in
            var episode = Episode(feedItem: feedItem)

            if episode.imageUrl == nil {
                episode.imageUrl = imageUrl
            }

            episodes.append(episode)
        })

        return episodes
    }
}

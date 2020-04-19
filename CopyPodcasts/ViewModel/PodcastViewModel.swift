//
//  PodcastViewModel.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 7. 6..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit

import Then

final class PodcastListViewModel {

    private var apiService: APIService
    private(set) var podcastViewModels = [PodcastViewModel]()

    private var searchCompletion: () -> () = {}

    private var timer: Timer?

    // TODO: Timer

    init(apiService: APIService, didSearch completion: @escaping () -> ()) {
        self.apiService = apiService
        self.searchCompletion = completion
    }

    var isEmpty: Bool {
        return podcastViewModels.isEmpty
    }

    func searchPodcasts(searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
            self.apiService.fetchPodcasts(searchText: searchText) { (podcasts) in
                self.podcastViewModels = podcasts.map(PodcastViewModel.init)
                self.searchCompletion()
            }
        })

    }
}

struct PodcastViewModel: Codable {

    let podcast: Podcast

    let title: String
    let artist: String
    let episodeString: String
    let artworkUrl: URL?

    enum CondingKeys: String, CodingKey {
        case title
        case artist
        case episodeString
        case artworkUrl
    }

    init(podcast: Podcast) {
        self.podcast = podcast

        self.title = podcast.trackName ?? "<NULL>"
        self.artist = podcast.artistName ?? "-"

        self.artworkUrl = URL(string: podcast.artworkURL600 ?? "")

        let count = podcast.trackCount ?? 0
        self.episodeString = count > 1
            ? "\(count) Episodes"
            : "\(count) Episode"
    }
}

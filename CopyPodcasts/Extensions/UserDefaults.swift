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
    static let downloadedEpisodesKey = "downloadedEpisodesKey"

    // MARK: - Downloaded Episodes
    func downloadEpisode(episode: Episode) {
        do {
            var episodes = UserDefaults.standard.downloadedEpisodes()
            episodes.insert(episode, at: 0)
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
        } catch let encodeErr {
            print("Failed to encode episode:", encodeErr)
        }
    }

    func downloadedEpisodes() -> [Episode] {
        guard let episodesData = data(forKey: UserDefaults.downloadedEpisodesKey) else { return [] }

        do {
            let episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
            return episodes
        } catch let decodeErr {
            print("Failed to decode:", decodeErr)
        }

        return []
    }

    func deleteDownloadedEpisode(at index: Int) {
        do {
            var episodes = downloadedEpisodes()
            episodes.remove(at: index)
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
        } catch let encodeErr {
            print("Failed to encode:", encodeErr)
        }
    }

    // MARK: - Favorite podcasts

    func savedPodcastViewModels() -> [PodcastViewModel] {
        guard let viewModelsData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey),
            let data = NSKeyedUnarchiver.unarchiveObject(with: viewModelsData) as? Data else { return [] }

        do {
            let viewModels = try PropertyListDecoder().decode([PodcastViewModel].self, from: data)
            return viewModels
        } catch {
            print("---Retrieve Failed")
            return []
        }
    }

    func deleteSavedPodcast(at index: Int) {
        // delete podcast from UserDefaults
        var savedPodcastViewModels = UserDefaults.standard.savedPodcastViewModels()

        savedPodcastViewModels.remove(at: index)
        let data = NSKeyedArchiver.archivedData(withRootObject: savedPodcastViewModels)
        UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)

    }
}

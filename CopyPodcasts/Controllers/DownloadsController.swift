//
//  DownloadsController.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 5. 7..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit

class DownloadsController: UITableViewController {
    
    fileprivate let cellID = "cellID"
    
    var episodes = UserDefaults.standard.downloadedEpisodes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupObservers()
    }
    
    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
    }
    @objc fileprivate func handleDownloadComplete(notification: Notification) {
        guard let episodeDownloadComplete = notification.object as? APIService.EpisodeDownloadCompleteTuple else { return }
        
        guard let index = self.episodes.firstIndex(where: { $0.title == episodeDownloadComplete.episodeTitle }) else { return }
        
        self.episodes[index].fileUrl = episodeDownloadComplete.fileUrl
        
    }
    @objc fileprivate func handleDownloadProgress(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String:Any] else { return }
        
        guard let progress = userInfo["progress"] as? Double else { return }
        
        guard let title = userInfo["title"] as? String else { return }
        
        print(progress, title)
        
        // let's find the index using title
        guard let index = self.episodes.firstIndex(where: { $0.title == title }) else { return }
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
        
        cell.progressLabel.text = "\(Int(progress * 100))%"
        cell.progressLabel.isHidden = false
        
        if progress == 1 {
            cell.progressLabel.isHidden = true
        }
    }
    
    
    fileprivate func refreshEpisodes() {
        episodes = UserDefaults.standard.downloadedEpisodes()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshEpisodes()
    }
    
    // MARK: - Setup
    
    fileprivate func setupTableView()   {
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellID)
    }
    
    
    // MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Launch episode player")
        let episode = self.episodes[indexPath.row]
        
        if episode.fileUrl != nil {
            UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
        } else {
            let alertController = UIAlertController(title: "File URL not found", message: "Cannot find local file, play using stream url instead", preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "YES", style: .default, handler: { (_) in
                UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            // for iPad
            if let popover = alertController.popoverPresentationController {
                let selectedCell = tableView.cellForRow(at: indexPath)
                popover.sourceView = selectedCell
                popover.sourceRect = (selectedCell?.bounds)!
            }
            
            present(alertController, animated: true, completion: nil)
        }
        
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, _) in
            UserDefaults.standard.deleteDownloadedEpisode(at: indexPath.row)
            self.episodes = UserDefaults.standard.downloadedEpisodes()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return [deleteAction]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! EpisodeCell
        
        cell.episode = self.episodes[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
}

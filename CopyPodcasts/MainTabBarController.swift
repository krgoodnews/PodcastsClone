//
//  MainTabBarController.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 2. 27..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit

import SnapKit

final class MainTabBarController: UITabBarController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		UINavigationBar.appearance().prefersLargeTitles = true
		
		tabBar.tintColor = .purple
		
		setupViewControllers()
		
		setupPlayerDetailsView()
		
	}
	
	@objc func minimizePlayerDetails() {
        playerDetailsView.snp.remakeConstraints {
            $0.bottom.equalTo(tabBar.snp.top)
            $0.height.equalTo(64)
            $0.leading.trailing.equalTo(view)
        }
		
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
			self.view.layoutIfNeeded()
            self.tabBar.isHidden = false
			self.playerDetailsView.backgroundMaximizedStackView.alpha = 0
			self.playerDetailsView.miniPlayerView.alpha = 1
		})
	}
	
	func maximizePlayerDetails(episode: Episode?, playlistEpisodes: [Episode] = []) {
        playerDetailsView.snp.remakeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.bottom.equalTo(view)
        }
		
		if episode != nil {
			playerDetailsView.episode = episode
		}
		
		playerDetailsView.playlistEpisodes = playlistEpisodes
		
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.view.layoutIfNeeded()
            self.tabBar.isHidden = true
			self.playerDetailsView.backgroundMaximizedStackView.alpha = 1
			self.playerDetailsView.miniPlayerView.alpha = 0
		})
	}
	
	// MARK: - setup Functions
	let playerDetailsView = PlayerDetailView.initFromNib()
	
    fileprivate func setupPlayerDetailsView() {
		view.insertSubview(playerDetailsView, belowSubview: tabBar)

		playerDetailsView.snp.remakeConstraints { make -> Void in
            make.bottom.equalTo(view.snp.bottom).offset(view.frame.height)
			make.leading.trailing.equalTo(self.view)
		}
	}
	
	// MARK: - Setup Functions
	
	func setupViewControllers() {
		let layout = UICollectionViewFlowLayout()
		let favoritesController = FavoritesController(collectionViewLayout: layout)
		viewControllers = [
			generateNavigationController(for: PodcastsSearchController(), title: "Search", img: #imageLiteral(resourceName: "search")),
			generateNavigationController(for: favoritesController, title: "Favorites", img: #imageLiteral(resourceName: "favorites")),
			
			generateNavigationController(for: DownloadsController(), title: "Downloads", img: #imageLiteral(resourceName: "downloads"))
		]
	}
	
	// MARK: - Helper Functions
	
	fileprivate func generateNavigationController(for rootVC: UIViewController, title: String, img: UIImage) -> UIViewController {
		let navController = UINavigationController(rootViewController: rootVC)
		rootVC.title = title
		navController.tabBarItem.title = title
		navController.tabBarItem.image = img
		
		return navController
	}
}

//
//  MainTabBarController.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 2. 27..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		UINavigationBar.appearance().prefersLargeTitles = true
		
		tabBar.tintColor = .purple
		
		setupViewControllers()
		
		setupPlayerDetailsView()
		
//		perform(#selector(maximizePlayerDetails), with: nil, afterDelay: 1)
	}
	
	@objc func minimizePlayerDetails() {
		
		maximizedTopAnchorConstraint.isActive = false
		minimizedTopAnchorConstraint.isActive = true
		
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.view.layoutIfNeeded()
			self.tabBar.transform = .identity
		}, completion: nil)
	}
	
	func maximizePlayerDetails(_ episode: Episode?) {
		maximizedTopAnchorConstraint.isActive = true
		maximizedTopAnchorConstraint.constant = 0
		minimizedTopAnchorConstraint.isActive = false
		
		if episode != nil {
			playerDetailsView.episode = episode
		}
		
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			self.view.layoutIfNeeded()
			self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
		}, completion: nil)
	}
	
	// MARK: - setup Functions
	let playerDetailsView = PlayerDetailView.initFromNib()

	var maximizedTopAnchorConstraint: NSLayoutConstraint!
	var minimizedTopAnchorConstraint: NSLayoutConstraint!
	
	
	fileprivate func setupPlayerDetailsView() {
		print("Setting up PlayerDetilsView")
		
		
		// use AutoLayout
		view.insertSubview(playerDetailsView, belowSubview: tabBar)
		
		playerDetailsView.translatesAutoresizingMaskIntoConstraints = false // enable AutoLayout
		
		maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)

		maximizedTopAnchorConstraint.isActive = true
		
		minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
		
//		minimizedTopAnchorConstraint.isActive = true
		
		playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
	}
	
	// MARK: - Setup Functions
	
	func setupViewControllers() {
		viewControllers = [
			generateNavigationController(for: PodcastsSearchController(), title: "Search", img: #imageLiteral(resourceName: "search")),
			generateNavigationController(for: ViewController(), title: "Favorites", img: #imageLiteral(resourceName: "favorites")),
			generateNavigationController(for: ViewController(), title: "Downloads", img: #imageLiteral(resourceName: "downloads"))
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

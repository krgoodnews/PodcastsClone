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
	}
	
	// MARK: - Setup Functions
	
	func setupViewControllers() {
		viewControllers = [
			generateNavigationController(for: ViewController(), title: "Favorites", img: #imageLiteral(resourceName: "favorites")),
			generateNavigationController(for: ViewController(), title: "Search", img: #imageLiteral(resourceName: "search")),
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

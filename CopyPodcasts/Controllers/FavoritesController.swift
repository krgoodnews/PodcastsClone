//
//  FavoritesController.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 5. 2..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit

class FavoritesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	
	fileprivate let cellID = "cellID"
	
	var podcasts = UserDefaults.standard.savedPodcasts()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupCollectionView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		podcasts = UserDefaults.standard.savedPodcasts()
		collectionView?.reloadData()
		UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = nil
	}
	
	fileprivate func setupCollectionView() {
		collectionView?.backgroundColor = .white
		collectionView?.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: cellID)
		
		let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
		collectionView?.addGestureRecognizer(gesture)
	}
	
	@objc private func handleLongPress(gesture: UILongPressGestureRecognizer) {
		print("Captured Long Press")
		
		let location = gesture.location(in: collectionView)
		
		guard let selectedIndexPath = collectionView?.indexPathForItem(at: location) else { return }

//		print(selectedIndexPath?.item)
		
		
		let alert = UIAlertController(title: "Remove Podcast?", message: nil, preferredStyle: .actionSheet)
		
		let deleteAction = UIAlertAction(title: "Yes", style: .destructive) { (_) in
			
			// delete podcast from UserDefaults
			var savedPodcasts = UserDefaults.standard.savedPodcasts()
//			listOfPodcasts.append(podcast)
			savedPodcasts.remove(at: selectedIndexPath.item)
			let data = NSKeyedArchiver.archivedData(withRootObject: savedPodcasts)
			UserDefaults.standard.set(data, forKey: UserDefaults.favoritedPodcastKey)
			
			
			// remove the podcast object from collection view
			self.podcasts.remove(at: selectedIndexPath.item)
			self.collectionView?.deleteItems(at: [selectedIndexPath])
			
			
			
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		
		alert.addAction(deleteAction)
		alert.addAction(cancelAction)
		
		// for iPad
		if let popover = alert.popoverPresentationController {
			let selectedCell = collectionView?.cellForItem(at: selectedIndexPath ?? IndexPath(item: 0, section: 0))
			popover.sourceView = selectedCell
			popover.sourceRect = (selectedCell?.bounds)!
		}
		
		present(alert, animated: true)
	}
	// MARK: - UICollectionView Delegate
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return podcasts.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! FavoritePodcastCell
		
		cell.podcast = self.podcasts[indexPath.item]
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		var width: CGFloat = 100
		
		switch UIDevice.current.userInterfaceIdiom {
		case .pad:
			width = 236
		default:
			width = (view.frame.width - 3 * 16) / 2
		}
		
		return CGSize(width: width, height: width + 46)

	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let episodesController = EpisodesController()
		
		episodesController.podcast = self.podcasts[indexPath.item]
		
		navigationController?.pushViewController(episodesController, animated: true)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 16
	}
}
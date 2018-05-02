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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupCollectionView()
	}
	
	fileprivate func setupCollectionView() {
		collectionView?.backgroundColor = .white
		collectionView?.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: cellID)
	}
	
	// MARK: - UICollectionView Delegate
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 5
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! FavoritePodcastCell
		
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let width = (view.frame.width - 3 * 16) / 2
		return CGSize(width: width, height: width + 46)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 16
	}
}

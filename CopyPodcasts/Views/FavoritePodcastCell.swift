//
//  FavoritePodcastCell.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 5. 2..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit
import SnapKit

final class FavoritePodcastCell: UICollectionViewCell {

    //	var podcast: Podcast! {
    //		didSet {
    //			nameLabel.text = podcast.trackName
    //			artistNameLabel.text = podcast.artistName
    //
    //			let url = URL(string: podcast.artworkURL600 ?? "")
    //			imageView.sd_setImage(with: url)
    //		}
    //	}

    var podcastViewModel: PodcastViewModel? {
        didSet {
            nameLabel.text = podcastViewModel?.title
            artistNameLabel.text = podcastViewModel?.artist

            let url = URL(string: podcastViewModel?.podcast.artworkURL600 ?? "")
            imageView.sd_setImage(with: url)
        }
    }

    let imageView = UIImageView(image: #imageLiteral(resourceName: "appicon"))
    let nameLabel = UILabel()
    let artistNameLabel = UILabel()

    fileprivate func stylizeUI() {
        nameLabel.text = "Podcast Name"
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        artistNameLabel.font = UIFont.systemFont(ofSize: 14)
        artistNameLabel.text = "Artist Name"
        artistNameLabel.textColor = .lightGray
    }

    fileprivate func setupViews() {
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true

        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel, artistNameLabel])

        stackView.axis = .vertical

        // enable auto layout
        addSubview(stackView)

        stackView.snp.remakeConstraints { make -> Void in
            make.edges.equalTo(self)
        }

    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        stylizeUI()
        setupViews()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  PlayerDetailsView+Gestures.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 4. 17..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit

extension PlayerDetailView {
    @objc func handlePan(gesture: UIPanGestureRecognizer) {

        if gesture.state == .changed {
            handlePanChanged(gesture: gesture)

        } else if gesture.state == .ended {

            handlePanEnded(gesture: gesture)
        }
    }

    func handlePanChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)

        self.miniPlayerView.alpha = 1 + translation.y / 200
        self.backgroundMaximizedStackView.alpha = -translation.y / 200

    }

    func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)


        print("Ended:", velocity.y)

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = .identity

            if translation.y < -200 || velocity.y < -500 {
                UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: nil)
            } else {
                self.miniPlayerView.alpha = 1
                self.backgroundMaximizedStackView.alpha = 0
            }

        })
    }
}

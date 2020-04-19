//
//  UIApplication.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 4. 17..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit

extension UIApplication {
    
    static func mainTabBarController() -> MainTabBarController? {

        return shared.keyWindow?.rootViewController as? MainTabBarController
    }
}

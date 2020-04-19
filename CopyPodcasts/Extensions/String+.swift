//
//  String+.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 3. 11..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import Foundation

extension String {
    func toSecureHTTPS() -> String {
        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
}

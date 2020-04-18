//
//  Dynamic.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 7. 10..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import Foundation

class Dynamic<T> {
	
	typealias Listener = (T) -> Void
	var listener :Listener?
	
	func bind(listener :Listener?) {
		self.listener = listener
		listener?(value!)
	}
	
	var value :T? {
		didSet {
			listener?(value!)
		}
	}
	
	init(_ v:T) {
		value = v
	}
	
}


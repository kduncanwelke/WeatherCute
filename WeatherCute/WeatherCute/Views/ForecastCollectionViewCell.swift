//
//  ForecastCollectionViewCell.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 6/1/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var cellTitle: UILabel!
	@IBOutlet weak var descrip: UILabel!
	@IBOutlet weak var cellTemp: UILabel!
	@IBOutlet weak var cellImage: UIImageView!
	
	weak var collectionDelegate: CollectionViewTapDelegate?
	
	override func awakeFromNib() {
		let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(recognizer: )))
		gesture.delegate = self as? UIGestureRecognizerDelegate
		cellImage.isUserInteractionEnabled = true
		cellImage.addGestureRecognizer(gesture)
	}
	
	@objc func handleTap(recognizer: UILongPressGestureRecognizer) {
		print("tap handled")
		collectionDelegate?.longPress(sender: self, state: recognizer.state)
	}
}

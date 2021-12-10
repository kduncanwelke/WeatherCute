//
//  ContentViewController.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/29/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import CoreData

class ContentViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

	// MARK: IBOutlets
	
	@IBOutlet weak var location: UILabel!
	@IBOutlet weak var temp: UILabel!
	@IBOutlet weak var descrip: UILabel!
	@IBOutlet weak var humidity: UILabel!
	@IBOutlet weak var dewpoint: UILabel!
	@IBOutlet weak var heatIndex: UILabel!
	@IBOutlet weak var heatIndexLabel: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var currentFrom: UILabel!
	@IBOutlet weak var largeImage: UIImageView!
    @IBOutlet weak var noImageText: UILabel!
    @IBOutlet weak var alertButton: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var collectionViewActivityIndicator: UIActivityIndicatorView!
	
	@IBOutlet weak var detailForecastDay: UILabel!
	@IBOutlet weak var detailForecastLabel: UILabel!
	@IBOutlet weak var detailBackground: UIView!
	@IBOutlet weak var reloadButton: UIButton!
	@IBOutlet weak var reloadActivityIndicator: UIActivityIndicatorView!
	
	// MARK: Variables
	
	private let contentViewModel = ContentViewModel()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		detailBackground.layer.cornerRadius = 15
		detailBackground.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
		detailBackground.isHidden = true

		collectionView.dataSource = self
		collectionView.delegate = self
		
		NotificationCenter.default.addObserver(self, selector: #selector(reloadCurrent), name: NSNotification.Name(rawValue: "reloadCurrent"), object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(degreeUnitChanged), name: NSNotification.Name(rawValue: "degreeUnitChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkRestored), name: NSNotification.Name(rawValue: "networkRestored"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(noNetwork), name: NSNotification.Name(rawValue: "noNetwork"), object: nil)
        
        NetworkMonitor.loadedItems = .none

        loadUI()
    }

	// MARK: Custom functions
    
    func loadUI() {
        location.text = contentViewModel.getLocationName()
        currentFrom.text = contentViewModel.getObservationName()
    }

	func displayCurrent() {
        temp.text = contentViewModel.getCurrentTemp()
        descrip.text = contentViewModel.getCurrentDescription()
        humidity.text = contentViewModel.getCurrentHumidity()
        dewpoint.text = contentViewModel.getCurrentDewpoint()
        heatIndex.text = contentViewModel.getCurrentHeatChill()
        heatIndexLabel.text = contentViewModel.setHeatChillLabel()

        if let weatherImage = contentViewModel.getCurrentConditionImage() {
            largeImage.image = weatherImage
            noImageText.isHidden = true
        } else {
            noImageText.isHidden = false
        }

        alertButton.isHidden = contentViewModel.hideAlertButton()
	}
    
    @objc func networkRestored() {
        print("network restored")
    }
    
    @objc func noNetwork() {

    }
	
	@objc func degreeUnitChanged() {
        temp.text = contentViewModel.getCurrentTemp()
        dewpoint.text = contentViewModel.getCurrentDewpoint()
        heatIndex.text = contentViewModel.getCurrentHeatChill()

        collectionView.reloadData()
	}

	
	@objc func reloadCurrent() {
        currentFrom.text = contentViewModel.getObservationName()
	}

	// MARK: IBActions
	
	@IBAction func changeButtonPressed(_ sender: UIButton) {
		performSegue(withIdentifier: "changeStation", sender: Any?.self)
	}
	
	@IBAction func alertButtonPressed(_ sender: UIButton) {
		performSegue(withIdentifier: "viewAlerts", sender: Any?.self)
	}
	
	@IBAction func reload(_ sender: UIButton) {
		reloadButton.setImage(UIImage(named: "loading"), for: .normal)
		reloadActivityIndicator.startAnimating()
		reloadButton.isEnabled = false
		print("reload")

		reloadActivityIndicator.stopAnimating()
		reloadButton.setImage(UIImage(named: "reload"), for: .normal)
		reloadButton.isEnabled = true
	}
	
}

extension ContentViewController: UICollectionViewDataSource, CollectionViewTapDelegate {
	func longPress(sender: ForecastCollectionViewCell, state: UIGestureRecognizer.State) {
		
        if state == .began {
			let path = self.collectionView.indexPath(for: sender)
			if let selected = path {
				detailBackground.popUp()
                detailForecastDay.text = contentViewModel.getForecastName(index: selected.row)
                detailForecastLabel.text = contentViewModel.getForecastDetail(index: selected.row)
			}
        } else if state == .ended {
            detailBackground.goDown()
        }
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentViewModel.getForecastCount()
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "forecastCell", for: indexPath) as! ForecastCollectionViewCell

        cell.cellTitle.text = contentViewModel.getForecastName(index: indexPath.row)
        cell.cellTemp.text = contentViewModel.getForecastTemp(index: indexPath.row)
        cell.cellImage.image = contentViewModel.getForecastIcon(index: indexPath.row)
        cell.descrip.text = contentViewModel.getForecastText(index: indexPath.row)

        cell.collectionDelegate = self
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		let cellWidth : CGFloat = 145.0
		
		let numberOfCells = floor(self.view.frame.size.width / cellWidth)
		let edgeInsets = (self.view.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1)
		
		return UIEdgeInsets(top: 0, left: edgeInsets, bottom: 20, right: edgeInsets)
	}
}


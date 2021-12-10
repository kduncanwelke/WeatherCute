//
//  ChangeObservationViewController.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 6/4/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class ChangeObservationViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	// MARK: IBOutlets

	@IBOutlet weak var collectionView: UICollectionView!
	
	// MARK: Variables
	
	var stations: [String] = []
	var stationNames: [String] = []

    private let observationViewModel = ObservationViewModel()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		collectionView.dataSource = self
		collectionView.delegate = self

        observationViewModel.removeResult()
		
        observationViewModel.getStations(completionHandler: { [unowned self] in
            self.collectionView.reloadData()
        })
    }
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	
	// MARK: IBActions
	
	@IBAction func cancelTapped(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}
}

extension ChangeObservationViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return observationViewModel.getStationCount()
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stationCell", for: indexPath) as! StationCollectionViewCell
		
        cell.cellLabel.text = observationViewModel.getLabel(index: indexPath.row)
        cell.nameLabel.text = observationViewModel.getName(index: indexPath.row)
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		let cellWidth : CGFloat = 145.0
		
		let numberOfCells = floor(self.view.frame.size.width / cellWidth)
		let edgeInsets = (self.view.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1)
		return UIEdgeInsets(top: 0, left: edgeInsets, bottom: 20, right: edgeInsets)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        observationViewModel.resaveObservation(index: indexPath.row)
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCurrent"), object: nil)
		self.dismiss(animated: true, completion: nil)
	}
}

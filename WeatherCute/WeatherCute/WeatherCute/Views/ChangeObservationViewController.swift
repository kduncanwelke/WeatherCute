//
//  ChangeObservationViewController.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 6/4/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class ChangeObservationViewController: UIViewController {
	
	// MARK: IBOutlets
	@IBOutlet weak var collectionView: UICollectionView!
	
	// MARK: Variables
	
	var stations: [String] = []
	var stationsLoaded = false
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		collectionView.dataSource = self
		collectionView.delegate = self
		
		getStations()
    }
	
	func getStations() {
		DataManager<Stations>.fetch() { [weak self] result in
			switch result {
			case .success(let response):
				DispatchQueue.main.async {
					guard let data = response.first?.features else { return }
					
					for item in data {
						self?.stations.append(item.properties.stationIdentifier)
					}
					
					self?.stationsLoaded = true
					self?.collectionView.reloadData()
				}
			case .failure(let error):
				print(error)
			}
		}
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
		return stations.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stationCell", for: indexPath) as! StationCollectionViewCell
		
		if stationsLoaded {
			cell.cellLabel.text = stations[indexPath.row]
		}
		
		return cell
	}
}

extension ChangeObservationViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		ForecastSearch.observationStation = stations[indexPath.row]
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadCurrent"), object: nil)
		self.dismiss(animated: true, completion: nil)
	}
}

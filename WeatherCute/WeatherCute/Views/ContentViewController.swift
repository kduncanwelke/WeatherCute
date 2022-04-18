//
//  ContentViewController.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 5/29/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var noNetworkLabel: UILabel!
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

        NotificationCenter.default.addObserver(self, selector: #selector(refreshContent), name: NSNotification.Name(rawValue: "refreshContent"), object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(degreeUnitChanged), name: NSNotification.Name(rawValue: "degreeUnitChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkRestored), name: NSNotification.Name(rawValue: "networkRestored"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkWhoops), name: NSNotification.Name(rawValue: "networkWhoops"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
	// MARK: Custom functions

    func getData() {
        if contentViewModel.getLocationsCount() == 0 {
            clear()
            return
        }

        clear()
        if !contentViewModel.isLoaded() {
            getData(reload: false)
        } else {
            displayCurrent()
        }
    }

    @objc func refreshContent() {
        getData()
    }

    func clear() {
        location.text = "-"
        currentFrom.text = ""
        temp.text = "-"
        descrip.text = "..."
        humidity.text = "-"
        dewpoint.text = "-"
        heatIndex.text = "-"
        heatIndexLabel.text = "Heat Index"
        collectionView.reloadData()
        alertButton.isHidden = true
        largeImage.image = nil
    }

    func getData(reload: Bool) {
        contentViewModel.setSearchParameters()
        collectionViewActivityIndicator.startAnimating()
        activityIndicator.startAnimating()

        if reload {
            reloadActivityIndicator.startAnimating()
            reloadButton.setImage(UIImage(named: "loading"), for: .normal)
            reloadButton.isEnabled = false
        }

        contentViewModel.getForecastData(completion: { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.collectionViewActivityIndicator.stopAnimating()
            }
        })

        contentViewModel.getWeatherData(completion: { [weak self] in
            DispatchQueue.main.async {
                self?.displayCurrent()
                self?.activityIndicator.stopAnimating()

                if reload {
                    self?.reloadButton.setImage(UIImage(named: "reload"), for: .normal)
                    self?.reloadActivityIndicator.stopAnimating()
                    self?.reloadButton.isEnabled = true
                }
            }
        })

        contentViewModel.getAlerts(completion: { [weak self] in
            DispatchQueue.main.async {
                self?.configureAlertButton()
            }
        })

    }

	func displayCurrent() {
        collectionViewActivityIndicator.startAnimating()
        activityIndicator.startAnimating()

        location.text = contentViewModel.getLocationName()
        currentFrom.text = contentViewModel.getObservationName()
        temp.text = contentViewModel.getCurrentTemp()
        descrip.text = contentViewModel.getCurrentDescription()
        humidity.text = contentViewModel.getCurrentHumidity()
        dewpoint.text = contentViewModel.getCurrentDewpoint()
        heatIndex.text = contentViewModel.getCurrentHeatChill()
        heatIndexLabel.text = contentViewModel.setHeatChillLabel()
        collectionView.reloadData()
        configureAlertButton()
        configureNetworkButton()

        if let weatherImage = contentViewModel.getCurrentConditionImage() {
            largeImage.image = weatherImage
            noImageText.isHidden = true
        } else {
            noImageText.isHidden = false
        }

        collectionViewActivityIndicator.stopAnimating()
        activityIndicator.stopAnimating()
	}

    func configureAlertButton() {
        alertButton.isHidden = contentViewModel.hideAlertButton()
    }

    func configureNetworkButton() {
        if contentViewModel.hasNetwork() {
            noNetworkLabel.isHidden = true
        } else {
            noNetworkLabel.isHidden = false
        }
    }
    
    @objc func networkRestored() {
        print("network restored")
        noNetworkLabel.isHidden = true
        refreshContent()
    }
    
    @objc func networkWhoops() {
        print("network whoops")
        noNetworkLabel.isHidden = false
        activityIndicator.stopAnimating()
        collectionViewActivityIndicator.stopAnimating()
        reloadActivityIndicator.stopAnimating()
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
        if contentViewModel.hasNetwork() {
            noNetworkLabel.isHidden = true
            print("load")
            getData(reload: true)
        } else {
            noNetworkLabel.isHidden = false
        }
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


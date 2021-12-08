//
//  EditViewController.swift
//  WeatherCute
//
//  Created by Kate Duncan-Welke on 12/8/21.
//  Copyright © 2021 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {

    // MARK: IBOutlets

    @IBOutlet weak var tableView: UITableView!

    // MARK: Variables

    private let editViewModel = EditViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
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

    @IBAction func dismissPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension EditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editViewModel.getTotalLocations()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath) as! EditTableViewCell

        cell.location.text = editViewModel.getPlaceName(index: indexPath.row)

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            editViewModel.removeLocation(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension EditViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = editViewModel.getPlaceName(index: indexPath.row)

        return [dragItem]
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update the model
        editViewModel.swap(source: sourceIndexPath.row, destination: destinationIndexPath.row)
    }
}

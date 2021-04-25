//
//  EventsViewController.swift
//  eKamera
//
//  Created by Кирилл Емельянов on 25.04.2021.
//

import UIKit

class EventsViewController: UITableViewController {
    var totalEvents = 0
    
    var cameraId: String? {
        didSet {
            self.title = "Камера"
            if let camName = cameraId {
                self.title! += " " + camName
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalEvents
    }
}

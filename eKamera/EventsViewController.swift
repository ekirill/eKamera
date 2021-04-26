//
//  EventsViewController.swift
//  eKamera
//
//  Created by Кирилл Емельянов on 25.04.2021.
//
import os
import UIKit

class EventsViewController: UITableViewController {
    var eventsRepository: Repository<Event>?
    var selectedEvent: Event?
    
    var cameraId: String? {
        didSet {
            self.title = "Камера"
            if let realCameraId = cameraId {
                self.title! += " " + realCameraId
                eventsRepository = Repository<Event>(
                    itemsFetcher: ApiClient.getEventsFetcher(forCameraId: realCameraId),
                    onSuccessFetch: { [weak self] in
                        if let self = self {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                )
            } else {
                eventsRepository = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let playerView = segue.destination as? EventPlayerViewController, segue.identifier == "showPlayer" {
            playerView.eventUrl = self.selectedEvent?.videoUrl
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let totalItems = eventsRepository?.totalItems {
            return totalItems
        }

        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpinnerCell", for: indexPath)

        guard let repository = eventsRepository else {
            os_log("repository for events is not set", log: OSLog.default, type: .error)
            return cell
        }

        if let event = repository.getItem(indexPath.row) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventRowCell", for: indexPath)

            guard let eventCell = cell as? EventRowCellView else {
                os_log("unexpected error, EventRowCell is not EventRowCellView", log: OSLog.default, type: .error)
                return cell
            }
            
            eventCell.configure(event)
            
            return eventCell
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let repository = eventsRepository, let event = repository.getItem(indexPath.row) else {
            os_log("unexpected error, could not find event data", log: OSLog.default, type: .error)
            return
        }
        
        self.selectedEvent = event
        performSegue(withIdentifier: "showPlayer", sender: self)
    }
}

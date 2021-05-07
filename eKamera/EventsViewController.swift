//
//  EventsViewController.swift
//  eKamera
//
//  Created by Кирилл Емельянов on 25.04.2021.
//
import os
import UIKit

class EventsViewController: UITableViewController {
    var selectedEvent: Event?
    
    // TODO: singletone or injection
    var dataSource: EKDataSource<Event>?
    
    var cameraId: String? {
        didSet {
            self.title = "Камера"
            if let realCameraId = cameraId {
                self.title! += " " + realCameraId
                dataSource = EKDataSource<Event>(
                    itemsFetcher: ApiClient.getEventsFetcher(forCameraId: realCameraId),
                    cellTemplateName: "EventRowCell"
                )
            }
            
            tableView.dataSource = dataSource
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let playerView = segue.destination as? EventPlayerViewController, segue.identifier == "showPlayer" {
            playerView.eventUrl = self.selectedEvent?.videoUrl
        }
    }
    
    @objc func refresh(sender:AnyObject)
    {
        dataSource?.clear()
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let src = dataSource, let event = src.getItem(indexPath.row, tableView: tableView) else {
            os_log("unexpected error, could not find event data", log: OSLog.default, type: .error)
            return
        }
        
        self.selectedEvent = event
        performSegue(withIdentifier: "showPlayer", sender: self)
    }
}

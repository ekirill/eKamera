//
//  CamerasViewController.swift
//  eKamera
//
//  Created by Кирилл Емельянов on 24.04.2021.
//

import os
import UIKit

class CamerasViewController: UITableViewController {
    var selectedCameraId: String?
    
    // TODO: singletone or injection
    var dataSource: EKDataSource = EKDataSource<Camera>(
        itemsFetcher: ApiClient.getCameras,
        cellTemplateName: "CameraRowCell"
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = dataSource

        // to remove empty rows after data
        tableView.tableFooterView = UIView()
        
        refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventsView = segue.destination as? EventsViewController, segue.identifier == "showEvents" {
            eventsView.cameraId = self.selectedCameraId
        }
    }
    
    @objc func refresh(sender:AnyObject)
    {
        dataSource.clear()
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.getItem(indexPath.row, tableView: tableView) else {
            os_log("unexpected error, could not find camera data", log: OSLog.default, type: .error)
            return
        }
        
        self.selectedCameraId = item.id
        performSegue(withIdentifier: "showEvents", sender: self)
    }
}

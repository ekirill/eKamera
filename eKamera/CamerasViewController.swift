//
//  CamerasViewController.swift
//  eKamera
//
//  Created by Кирилл Емельянов on 24.04.2021.
//

import os
import UIKit

class CamerasViewController: UITableViewController {
    var camerasRepository: Repository<Camera>?
    var selectedCameraId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        camerasRepository = Repository<Camera>(
            itemsFetcher: ApiClient.getCameras,
            onSuccessFetch: { [weak self] in
                if let self = self {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventsView = segue.destination as? EventsViewController, segue.identifier == "showEvents" {
            eventsView.cameraId = self.selectedCameraId
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let repository = camerasRepository {
            return repository.totalItems
        }

        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpinnerCell", for: indexPath)

        if let repository = camerasRepository, let camera = repository.getItem(indexPath.row) {
            guard let cameraCell = tableView.dequeueReusableCell(withIdentifier: "CameraRowCell", for: indexPath) as? CameraRowCellView else {
                os_log("unexpected error, could not fetch camera data", log: OSLog.default, type: .error)
                return cell
            }

            cameraCell.configure(camera)
            
            return cameraCell
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let repository = camerasRepository, let camera = repository.getItem(indexPath.row) else {
            os_log("unexpected error, could not find camera data", log: OSLog.default, type: .error)
            return
        }
        
        self.selectedCameraId = camera.id
        performSegue(withIdentifier: "showEvents", sender: self)
    }
}

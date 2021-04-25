//
//  CamerasViewController.swift
//  eKamera
//
//  Created by Кирилл Емельянов on 24.04.2021.
//

import os
import UIKit

class CamerasViewController: UITableViewController {
    let camerasRepository = Repository<Camera>(itemsFetcher: ApiClient.getCameras)
    var selectedCameraId: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        camerasRepository.fetchFirst() {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return camerasRepository.totalItems
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CameraRowCell", for: indexPath)

        guard let cameraCell = cell as? CameraRowCellView else {
            os_log("unexpected error, CameraRowCell is not CameraRowCellView", log: OSLog.default, type: .error)
            return cell
        }
        
        guard let camera = camerasRepository.getItem(indexPath.row) else {
            os_log("unexpected error, could not find camera data", log: OSLog.default, type: .error)
            return cell
        }

        cameraCell.configure(camera)

        return cameraCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let camera = camerasRepository.getItem(indexPath.row) else {
            os_log("unexpected error, could not find camera data", log: OSLog.default, type: .error)
            return
        }
        
        self.selectedCameraId = camera.id
        performSegue(withIdentifier: "showEvents", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

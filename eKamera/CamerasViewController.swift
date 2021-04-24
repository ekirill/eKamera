//
//  CamerasViewController.swift
//  eKamera
//
//  Created by Кирилл Емельянов on 24.04.2021.
//

import os
import UIKit

class CamerasViewController: UITableViewController {
    let apiClient = ApiClient()
    var cameras: [String:Camera] = [:]
    var camerasOrder: [String] = []
    var totalCameras = 0
    var pagesLoaded = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPage()
    }
    
    func fetchPage() {
        let pageToLoad = self.pagesLoaded + 1
        
        apiClient.getCameras(page: pageToLoad) { response in
            self.totalCameras = response.count
            self.pagesLoaded = pageToLoad
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            for camera in response.results {
                self.cameras[camera.id] = camera
                self.camerasOrder.append(camera.id)
                os_log("got camera UID: %s [%s]", log: OSLog.default, type: .debug, camera.id, camera.caption)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalCameras
    }
    
    func getCamera(_ indexPath: IndexPath) -> Camera? {
        var camera: Camera?

        if indexPath.row < self.camerasOrder.count {
            let cameraUid = self.camerasOrder[indexPath.row]
            camera = self.cameras[cameraUid]
        }
        
        return camera
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let camera = getCamera(indexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CameraRowCell", for: indexPath)
            if let cameraCell = cell as? CameraRowCellView {
                cameraCell.configure(camera)
            }

            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "SpinnerCell", for: indexPath)
        }
    }

}

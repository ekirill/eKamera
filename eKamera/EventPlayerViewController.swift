//
//  EventPlayerViewController.swift
//  eKamera
//
//  Created by Кирилл Емельянов on 25.04.2021.
//

import UIKit
import AVKit

class EventPlayerViewController: AVPlayerViewController {
    var eventUrl: String?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let urlString = eventUrl, let url = URL(string: urlString) {
            let eventPlayer = AVPlayer(url: url)
            player = eventPlayer
            player?.play()
        }
    }
}

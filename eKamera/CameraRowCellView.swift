import os
import UIKit


class CameraRowCellView : UITableViewCell, ConfigurableCell {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    
    func configure(_ item: Any) {
        thumbnail.image = nil
        caption.text = ""
        self.spinner.startAnimating()

        guard let camera = item as? Camera else {
            os_log("unexpected error, expected Camera for data, got unknown", log: OSLog.default, type: .error)
            self.spinner.stopAnimating()
            
            return
        }
        
        caption.text = camera.caption

        if let imageUrl = camera.thumbnailUrl {
            spinner.startAnimating()
            ApiClient.getThumbnail(thumnailUrl: imageUrl) { image in
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.thumbnail.image = image
                }
            }
        }
    }
}

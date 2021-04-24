import UIKit


class CameraRowCellView : UITableViewCell {
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    
    func configure(_ camera: Camera) {
        thumbnail.image = nil
        caption.text = camera.caption

        if let imageUrl = camera.thumbnailUrl {
            spinner.startAnimating()
            ApiClient().getThumbnail(thumnailUrl: imageUrl) { image in
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.thumbnail.image = image
                }
            }
        }
    }
}

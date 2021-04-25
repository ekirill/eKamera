import UIKit


class EventRowCellView : UITableViewCell {
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    func configure(_ event: Event) {
        thumbnail.image = nil
        startTime.text = event.startTime
        duration.text = "\(event.duration) сек"

        if let imageUrl = event.thumbnailUrl {
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

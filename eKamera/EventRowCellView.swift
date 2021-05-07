import os
import UIKit


class EventRowCellView : UITableViewCell, ConfigurableCell {
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let dateExtracter = ISO8601DateFormatter()
    let dateFormatter = DateFormatter()
    
    let fluentDates: [Int:String] = [
        0: "Сегодня",
        1: "Вчера",
    ]

    func configure(_ item: Any) {
        thumbnail.image = nil
        self.spinner.startAnimating()
        startDate.text = ""
        startTime.text = ""
        duration.text = ""

        guard let event = item as? Event else {
            os_log("unexpected error, expected Event for data, got unknown", log: OSLog.default, type: .error)
            self.spinner.stopAnimating()

            return
        }

        duration.text = "\(event.duration) сек"

        if let dt = dateExtracter.date(from: event.startTime) {
            let now = Date()
            if let nowDayOfEra = Calendar.current.ordinality(of: .day, in: .era, for: now),
               let dtDayOfEra = Calendar.current.ordinality(of: .day, in: .era, for: dt)
            {
                if let fluent = fluentDates[nowDayOfEra-dtDayOfEra] {
                    startDate.text = fluent
                } else {
                    dateFormatter.dateFormat = "E, d MMM y"
                    startDate.text = dateFormatter.string(from: dt)
                }
            }

            dateFormatter.dateFormat = "HH:mm"
            startTime.text = dateFormatter.string(from: dt)
        }

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

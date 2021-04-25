import UIKit


class EventRowCellView : UITableViewCell {
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

    func configure(_ event: Event) {
        thumbnail.image = nil
        duration.text = "\(event.duration) сек"

        startDate.text = ""
        startTime.text = ""
        if let dt = dateExtracter.date(from: event.startTime) {
            let now = Date()
            if let nowDayOfEra = Calendar.current.ordinality(of: .day, in: .era, for: now), let dtDayOfEra = Calendar.current.ordinality(of: .day, in: .era, for: dt) {
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

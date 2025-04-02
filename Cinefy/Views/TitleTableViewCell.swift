
import UIKit

class TitleTableViewCell: UITableViewCell {
    static let identifier = "TitleTableViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2  // Allow two lines for description
        label.textColor = .lightGray  // Light gray for description
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let movieTypeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .systemYellow  // Make it stand out with a different color
        label.font = .systemFont(ofSize: 12, weight: .bold)
        return label
    }()

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .black
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(movieTypeLabel) // Add the new label
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = 100
        posterImageView.frame = CGRect(x: 10,
                                      y: (contentView.frame.height - imageSize) / 2,
                                      width: imageSize,
                                      height: imageSize)
        
        titleLabel.frame = CGRect(x: posterImageView.frame.maxX + 15,
                                 y: contentView.frame.height / 2 - 50,
                                 width: contentView.frame.width - posterImageView.frame.maxX - 30,
                                 height: 30)
        
        descriptionLabel.frame = CGRect(x: posterImageView.frame.maxX + 15,
                                       y: titleLabel.frame.maxY + 2,
                                       width: contentView.frame.width - posterImageView.frame.maxX - 30,
                                       height: 40)
        
        // Position the movie type label below the description
        movieTypeLabel.frame = CGRect(x: posterImageView.frame.maxX + 15,
                                     y: descriptionLabel.frame.maxY + 2,
                                     width: contentView.frame.width - posterImageView.frame.maxX - 30,
                                     height: 20)
    }

    func configure(with model: TitleViewModel) {
        // Update to include release year with the title
        if model.releaseYear == "N/A" {
            titleLabel.text = model.titleName
        } else {
            titleLabel.text = "\(model.titleName) (\(model.releaseYear))"
        }
        
        // Set the description text
        descriptionLabel.text = model.overview
        
        // Set the movie type
        movieTypeLabel.text = model.movieType
        
        if let url = URL(string: "https://image.tmdb.org/t/p/w500\(model.posterURL)") {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.posterImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
}



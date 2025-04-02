import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func searchResultsViewControllerDidTapItem(_ viewModel: TitlePreviewViewModel, title: Title)
}
class SearchResultsViewController: UIViewController {
    public var titles: [Title] = [Title]()
   // public weak var delegate: SearchResultsViewControllerDelegate?
    weak var delegate: SearchResultsViewControllerDelegate?

    public let searchResultsTableView: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        table.backgroundColor = .black
        table.separatorColor = .white
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(searchResultsTableView)

        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchResultsTableView.frame = view.bounds
    }
}

extension SearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else {
            return UITableViewCell()
        }
        
        let title = titles[indexPath.row]
        let releaseYear: String
        if let releaseDate = title.release_date, !releaseDate.isEmpty {
            let yearEndIndex = releaseDate.index(releaseDate.startIndex, offsetBy: 4)
            releaseYear = String(releaseDate[..<yearEndIndex])
        } else if let firstAirDate = title.first_air_date, !firstAirDate.isEmpty {
            let yearEndIndex = firstAirDate.index(firstAirDate.startIndex, offsetBy: 4)
            releaseYear = String(firstAirDate[..<yearEndIndex])
        } else {
            releaseYear = "N/A"
        }
       
        let shortOverview = title.overview?.prefix(100).appending(title.overview!.count > 100 ? "..." : "") ?? "No description available"
        let movieType = determineMovieType(title: title)
        let model = TitleViewModel(
            titleName: title.original_name ?? title.original_title ?? "Unknown name",
            posterURL: title.poster_path ?? "",
            releaseYear: releaseYear,
            overview: String(shortOverview),
            movieType: movieType
        )
        
        cell.configure(with: model)
        cell.backgroundColor = .black
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .lightGray
        return cell
    }
    
    private func determineMovieType(title: Title) -> String {
        if let _ = title.first_air_date, title.first_air_date?.isEmpty == false {
            return "TV SERIES"
        }
        if let _ = title.release_date, title.release_date?.isEmpty == false {
            if title.vote_average >= 8.0 {
                return "BLOCKBUSTER"
            } else if title.vote_average >= 7.0 {
                return "FEATURE FILM"
            } else {
                return "MOVIE"
            }
        }
        if let popularity = title.popularity {
            if popularity > 1000 {
                return "TRENDING"
            }
        }
        return "ENTERTAINMENT"
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        guard let titleName = title.original_title ?? title.original_name else { return }
        
        APICaller.shared.getMovie(with: titleName) { [weak self] result in
            switch result {
            case .success(let videoElement):
                DispatchQueue.main.async {
                    let viewModel = TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: title.overview ?? "")
                    self?.delegate?.searchResultsViewControllerDidTapItem(viewModel, title: title) // Pass the Title object
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    }


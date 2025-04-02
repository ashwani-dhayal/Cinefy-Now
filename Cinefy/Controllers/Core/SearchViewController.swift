import UIKit

class SearchViewController: UIViewController {
    private var titles: [Title] = [Title]()

    private let discoverTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        table.backgroundColor = .black
        return table
    }()
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: SearchResultsViewController())
        controller.searchBar.placeholder = "Search for a Movie or a TV Show"
        controller.searchBar.searchBarStyle = .minimal
        controller.searchBar.tintColor = .white
        
        let textField = controller.searchBar.searchTextField
        textField.backgroundColor = .darkGray
        textField.textColor = .white
        textField.tintColor = .white
        textField.keyboardAppearance = .dark
        
        // Placeholder color remains light gray
        textField.attributedPlaceholder = NSAttributedString(
            string: "Search for a Movie or a TV Show",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )

        return controller
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .black
        view.addSubview(discoverTable)
        
        discoverTable.delegate = self
        discoverTable.dataSource = self
        discoverTable.separatorColor = .white
        
        navigationItem.searchController = searchController
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        fetchDiscoverMovies()
        searchController.searchResultsUpdater = self
    }
    private func fetchDiscoverMovies() {
        APICaller.shared.getDiscoverMovies { [weak self] result in
            switch result {
            case .success(let titles):
                self?.titles = titles
                DispatchQueue.main.async {
                    self?.discoverTable.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        discoverTable.frame = view.bounds
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
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
        return 160 // Increased from 140 to fit the new movie type label
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        guard let titleName = title.original_title ?? title.original_name else { return }
        
        APICaller.shared.getMovie(with: titleName) { [weak self] result in
            switch result {
            case .success(let videoElement):
                DispatchQueue.main.async {
                    let vc = TitlePreviewViewController()
                    let viewModel = TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: title.overview ?? "")
                    vc.configure(with: viewModel, title: title) // Pass the Title object
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension SearchViewController: UISearchResultsUpdating, SearchResultsViewControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count >= 3,
              let resultsController = searchController.searchResultsController as? SearchResultsViewController else {
                  return
              }
        
        resultsController.delegate = self // Set the delegate
        APICaller.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let titles):
                    resultsController.titles = titles
                    resultsController.searchResultsTableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func searchResultsViewControllerDidTapItem(_ viewModel: TitlePreviewViewModel, title: Title) {
        DispatchQueue.main.async { [weak self] in
            let vc = TitlePreviewViewController()
            vc.configure(with: viewModel, title: title) // Pass the Title object
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}


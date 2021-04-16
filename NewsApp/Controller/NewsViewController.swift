//
//  ViewController.swift
//  NewsApp
//
//  Created by Maksim Velich on 21.03.21.
//

import UIKit
import Kingfisher
import CoreData

class NewsViewController: UIViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private let networkManager = NetworkManager()
    private let databaseManager = DatabaseManager()
    private var newsArray = [News]()
    private var filteredNews = [News]()
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    private var createSpinner: UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.frame = footerView.frame
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorColor = .systemRed
            addRefreshControll()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        receiveNewsData()
    }
    
    private func receiveNewsData() {
        if UserDefaultsManager.sessionNumber() == 1 {
            networkManager.performRequest(refreshData: true, counter: UserDefaultsManager.scrollCounterNumber()) { [weak self] in
                guard let self = self else { return }
                self.databaseManager.fetchNewsFromDB(to: &self.newsArray) {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        } else {
            databaseManager.fetchNewsFromDB(to: &self.newsArray) {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc private func didPullToRefresh() {
        UserDefaults.standard.set(0, forKey: UserDefaults.AppSettings.StringDefaultKey.scrollNumber.rawValue)
        networkManager.performRequest(refreshData: true, counter: UserDefaultsManager.scrollCounterNumber()) { [weak self] in
            guard let self = self else { return }
            self.databaseManager.fetchNewsFromDB(to: &self.newsArray) {
                DispatchQueue.main.async {
                    self.tableView.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func addRefreshControll() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = .red
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
}

//MARK: - UITableViewDataSource
extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let result = isFiltering ? filteredNews.count : newsArray.count
        return result
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.reusableTableCellIdentifier.rawValue, for: indexPath) as! NewsTableViewCell
        cell.customCellDelegate = self
        let news = isFiltering ? filteredNews[indexPath.row] : newsArray[indexPath.row]
        cell.updateCell(with: news)
        return cell
    }
}

//MARK: - UITableViewDelegate
extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == newsArray.count - 1 && UserDefaultsManager.scrollCounterNumber() < Constants.DataValues.maxPaginationDays.hashValue {
            UserDefaultsManager.countScrollNumber()
            tableView.tableFooterView = createSpinner
            networkManager.performRequest(refreshData: false, counter: UserDefaultsManager.scrollCounterNumber()) { [weak self] in
                guard let self = self else { return }
                self.databaseManager.fetchNewsFromDB(to: &self.newsArray) {
                    DispatchQueue.main.async {
                        self.tableView.tableFooterView = nil
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: - UISearchResultsUpdating $ UISearchBarDelegate
extension NewsViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredNews = newsArray.filter {
            $0.title!.contains(searchText)
        }
        tableView.reloadData()
        tableView.tableFooterView = UIView()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        for subview in self.tableView.subviews {
            if let refresh = subview as? UIRefreshControl {
                refresh.removeFromSuperview()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        addRefreshControll()
    }
}

// MARK: - CustomCellDelegate
extension NewsViewController: CustomCellDelegate {
    func didPressShowButton(_ cell: NewsTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let news = isFiltering ? filteredNews[indexPath.row] : newsArray[indexPath.row]
            let isOpen = cell.showMoreLessButton.titleLabel?.text == "Show More"
            cell.descriptionTextLabel.numberOfLines = isOpen ? 0 : 3
            cell.showMoreLessButton.setTitle(isOpen ? "Show Less" : "Show More", for: .normal)
            news.isOpen = isOpen
            tableView.reloadData()
        }
    }
}

// MARK: - SearchBar config
extension NewsViewController {
    private func configureSearchBar() {
        navigationItem.titleView = searchController.searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.definesPresentationContext = true
        searchController.searchBar.delegate = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.returnKeyType = .done
        searchController.searchBar.backgroundColor = .systemRed
        searchController.searchBar.tintColor = .white
        searchController.searchBar.searchTextField.layer.borderWidth = 0.2
        searchController.searchBar.searchTextField.layer.cornerRadius = 10
        searchController.searchBar.searchTextField.layer.borderColor = UIColor.black.cgColor
        searchController.searchBar.searchTextField.textColor = .black
        searchController.searchBar.searchTextField.placeholder = "Search by title"
        searchController.searchBar.searchTextField.autocapitalizationType = .sentences
        searchController.hidesNavigationBarDuringPresentation = false
    }
}

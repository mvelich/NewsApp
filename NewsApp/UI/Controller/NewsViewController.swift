//
//  ViewController.swift
//  NewsApp
//
//  Created by Maksim Velich on 21.03.21.
//

import UIKit
import Kingfisher

class NewsViewController: UIViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let searchController = UISearchController(searchResultsController: nil)
    private let newsManager = NewsManager()
    private var filteredNews = [News]()
    private let maxDaysValue = 7
    private var scrollCounter = 0
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
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
        didAppLaunchBeforeCheck()
    }
    
    private func didAppLaunchBeforeCheck() {
        if appLaunchedFirstTime {
            newsManager.performRequest(refreshData: false, counter: scrollCounter) { [weak self] in
                guard let self = self else { return }
                self.fetchNewsFromDB()
            }
        } else {
            fetchNewsFromDB()
        }
    }
    
    private func fetchNewsFromDB() {
        do {
            newsManager.newsArray = try context.fetch(News.fetchRequest())
            if newsManager.newsArray.isEmpty {
                scrollCounter += 1
                newsManager.performRequest(refreshData: true, counter: scrollCounter) { [weak self] in
                    guard let self = self else { return }
                    self.fetchNewsFromDB()
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch let dbError as NSError {
            print("Unexpected error during retrieving data: \(dbError).")
        }
    }
    
    @objc private func didPullToRefresh() {
        scrollCounter = 0
        newsManager.performRequest(refreshData: true, counter: scrollCounter) {
            self.fetchNewsFromDB()
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
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
    
    private func createSpinner() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.frame = footerView.frame
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
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
        let result = isFiltering ? filteredNews.count : newsManager.newsArray.count
        return result
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.reusableTableCellIdentifier.rawValue, for: indexPath) as! NewsTableViewCell
        cell.customCellDelegate = self
        let news = isFiltering ? filteredNews[indexPath.row] : newsManager.newsArray[indexPath.row]
        cell.updateCell(with: news)
        return cell
    }
}

//MARK: - UITableViewDelegate
extension NewsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.newsManager.newsArray.count - 1 && scrollCounter < maxDaysValue {
            scrollCounter += 1
            tableView.tableFooterView = createSpinner()
            newsManager.performRequest(refreshData: false, counter: scrollCounter) { [weak self] in
                guard let self = self else { return }
                self.fetchNewsFromDB()
                DispatchQueue.main.async {
                    self.tableView.tableFooterView = nil
                    self.tableView.reloadData()
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
        filteredNews = newsManager.newsArray.filter {
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
            let news = isFiltering ? filteredNews[indexPath.row] : newsManager.newsArray[indexPath.row]
            let isOpen = cell.showMoreLessButton.titleLabel?.text == "Show More"
            cell.descriptionTextLabel.numberOfLines = isOpen ? 0 : 3
            cell.showMoreLessButton.setTitle(isOpen ? "Show Less" : "Show More", for: .normal)
            news.isOpen = isOpen
            tableView.reloadData()
        }
    }
}

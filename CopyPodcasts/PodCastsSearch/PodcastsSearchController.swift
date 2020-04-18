//
//  PodcastsSearchController.swift
//  CopyPodcasts
//
//  Created by Goodnews on 2018. 2. 27..
//  Copyright © 2018년 krgoodnews. All rights reserved.
//

import UIKit

private let cellID = "podcastCellID"

class PodcastsSearchController: UITableViewController {

    //TODO: private var apiService: APIService = APIService()
    private var apiService: APIService!
    private var podcastListViewModel :PodcastListViewModel!
    private var dataSource: TableViewDataSource<PodcastCell, PodcastViewModel>!

    // lets implement a UISearchController
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupVM()
        setupSearchBar()
        setupTableView()

        searchBar(searchController.searchBar, textDidChange: "coding") // for testing
    }

    func setupVM() {
        self.apiService = APIService()
        self.podcastListViewModel = PodcastListViewModel(apiService: apiService, didSearch: {
            self.dataSource = TableViewDataSource(cellID: cellID, items: self.podcastListViewModel.podcastViewModels) { (cell, vm) in
                cell.podcastViewModel = vm
            }

            self.tableView.dataSource = self.dataSource
            self.tableView.reloadData()
        })
    }

    // MARK: - Setup Work

    fileprivate func setupSearchBar() {
        self.definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }

    fileprivate func setupTableView() {

        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellID)
    }

    // MARK: - TableView

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = self.podcastListViewModel.podcastViewModels[indexPath.row]
        let episodeController = EpisodesController()
        episodeController.podcastViewModel = viewModel
        navigationController?.pushViewController(episodeController, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }

    // MARK: header & footer

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter a Search Term"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // terary operator
        return self.podcastListViewModel.isEmpty ? 250 : 0
    }
}

extension PodcastsSearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        podcastListViewModel.searchPodcasts(searchText: searchText)
    }
}

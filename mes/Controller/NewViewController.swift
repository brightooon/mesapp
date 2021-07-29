//
//  NewViewController.swift
//  mes
//
//  Created by Chun Hei Law on 7/29/21.
//

import UIKit
import JGProgressHUD

class NewViewController: UIViewController {
    private let spinner = JGProgressHUD()
    private let searchbar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.placeholder = "search for users"
        return searchbar
    }()
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noResults: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 22, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchbar.delegate = self
        view.backgroundColor = .darkGray
        navigationController?.navigationBar.topItem?.titleView = searchbar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        searchbar.becomeFirstResponder()
    }
    @objc private func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }
}

extension NewViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    }
}

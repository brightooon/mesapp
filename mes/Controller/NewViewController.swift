//
//  NewViewController.swift
//  mes
//
//  Created by Chun Hei Law on 7/29/21.
//

import UIKit
import JGProgressHUD

class NewViewController: UIViewController {
    public var completion: (([String: String]) -> (Void))?
    
    private let spinner = JGProgressHUD(style: .dark)
    private var users = [[String: String]]()
    private var fetched = false
    private var results = [[String: String]]()
    
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
        view.addSubview(noResults)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        searchbar.delegate = self
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchbar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        searchbar.becomeFirstResponder()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResults.frame = CGRect(x: view.width/4, y: (view.height - 200)/2, width: view.width/2, height: 200)
    }
    @objc private func dismissSelf(){
        dismiss(animated: true, completion: nil)
    }
}
extension NewViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //start conservation
        let targetUser = results[indexPath.row]
        dismiss(animated: true, completion: {[weak self] in
            self?.completion?(targetUser)
        })
    }
}

extension NewViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else{
            return
        }
        results.removeAll()
        spinner.show(in: view)
        self.searchUser(query: text)
    }
    func searchUser(query: String){
        if fetched{
            print("found")
            filterUser(with: query)
        }
        else{
            databaseset.shared.alluser(completion: { [weak self] result in
                switch result{
                case .success(let userCollection):
                    self?.fetched = true
                    self?.users = userCollection
                    self?.filterUser(with: query)
                case .failure(let error):
                    print("failed to get users: \(error)")
                }
            })
        }
    }
    func filterUser(with term: String){
        // result or no result label
        guard fetched else{
            print("sth wrong")
            return
        }
        self.spinner.dismiss()
        let results: [[String: String]] = users.filter({
            guard let name = $0["name"]?.lowercased() else{
                print("lowercase failed")
                return false
            }
            return name.contains(term.lowercased())
        })
        self.results = results
        update()
    }
    
    func update(){
        if results.isEmpty{
            noResults.isHidden = false
            tableView.isHidden = true
            print("isempty")
        }
        else{
            noResults.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
            print("notempty")
        }
    }
}

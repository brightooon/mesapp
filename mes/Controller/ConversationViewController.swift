//
//  ViewController.swift
//  mes
//
//  Created by Chun Hei Law on 7/19/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD


class ConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self , forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noConversation: UILabel = {
        let label = UILabel()
        label.text = "No Conversation"
        label.textAlignment = .center
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didcomposeButton))
        view.addSubview(tableView)
        view.addSubview(noConversation)
        setuptableView()
        fetchConservation()
        // Do any additional setup after loading the view.
        //view.backgroundColor = .systemTeal
        
    }
    @objc private func didcomposeButton(){
        let vc = NewViewController()
        vc.completion = {[weak self] result in
            print("\(result)")
            self?.createConversation(result: result)
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    private func createConversation(result: [String: String]){
        guard let name = result["name"], let email = result["email"] else {
            return
        }
        let vc = ChatViewController(with: email)
        vc.isNewchat = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        validateac()
        }
    private func validateac(){
        if FirebaseAuth.Auth.auth().currentUser == nil{
            let x = LoginViewController()
            let y = UINavigationController(rootViewController: x)
            y.modalPresentationStyle = .fullScreen
            present(y, animated: false)
        }
    }
    
    private func setuptableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchConservation(){
        tableView.isHidden = false
    }
}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatViewController(with: "hello@gmail.com")
        vc.title = "Some One"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

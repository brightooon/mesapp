//
//  ViewController.swift
//  mes
//
//  Created by Chun Hei Law on 7/19/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

struct conversation {
    let id: String
    let name: String
    let targetemail: String
    let latestMessage: LatestMessage
}
struct LatestMessage{
    let date: String
    let text: String
    let read: Bool
}

class ConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    private var conversations = [conversation]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self , forCellReuseIdentifier: ConversationTableViewCell.identifier)
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
        listenConversation()
        //view.backgroundColor = .systemTeal
        
    }
    private func listenConversation(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        print("start conversation fetch\n")
        let safeemail = databaseset.safeemail(email: email)
        databaseset.shared.getConversation(for: safeemail, completion: { [weak self]result in
            switch result{
            case .success(let conversations):
                print("got conversation model")
                guard !conversations.isEmpty else{
                    return
                }
                self?.conversations = conversations
                DispatchQueue.main.async{
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print("yes failed: \(error)")
            }
        })
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
        
        let vc = ChatViewController(with: email, id: nil)
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
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        
        let vc = ChatViewController(with: model.targetemail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

//
//  ProfileViewController.swift
//  mes
//
//  Created by Chun Hei Law on 7/20/21.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class ProfileViewController: UIViewController {

    @IBOutlet var tableview: UITableView!
    let status = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableview.delegate = self
        tableview.dataSource = self
        // Do any additional setup after loading the view.
    }

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return status.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = status[indexPath.row]
        cell .textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .systemBlue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        let action = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        action.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            guard let strongself = self else{
                return
            }
            // facebook log out
            FBSDKLoginKit.LoginManager().logOut()
            do{
                try FirebaseAuth.Auth.auth().signOut()
                
                let x = LoginViewController()
                let y = UINavigationController(rootViewController: x)
                y.modalPresentationStyle = .fullScreen
                strongself.present(y, animated: false)
            }
            catch{
                print("Failed to log out")
            }
        }))
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(action, animated: true)
        
    }
}

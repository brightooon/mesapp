//
//  ProfileViewController.swift
//  mes
//
//  Created by Chun Hei Law on 7/20/21.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import SDWebImage

enum ProfileViewModelType{
    case info, logout
}

struct ProfileViewModel{
    let ViewModelType: ProfileViewModelType
    let details: String
    let handler: (() -> Void)?
}
class ProfileViewController: UIViewController {

    @IBOutlet var tableview: UITableView!
    var status = [ProfileViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        status.append(ProfileViewModel(ViewModelType: .info, details: "User: \(UserDefaults.standard.value(forKey: "name") as? String ?? "None")", handler: nil))
        status.append(ProfileViewModel(ViewModelType: .info, details: "Email: \(UserDefaults.standard.value(forKey: "email") as? String ?? "None")", handler: nil))
        status.append(ProfileViewModel(ViewModelType: .info, details: "Log Out", handler: {[weak self] in
            guard let strongself = self else{
                return
            }
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
            strongself.present(action, animated: true)
        }))
        tableview.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableview.delegate = self
        tableview.dataSource = self
        tableview.tableHeaderView = createTable()
        // Do any additional setup after loading the view.
    }
    func createTable() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeemail = databaseset.safeemail(email: email)
        let filename = safeemail + "_profile_picture_png"
        let path = "images/" + filename
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 275))
        view.backgroundColor = .systemBackground
        let imageView = UIImageView(frame: CGRect(x: (view.width-150)/2.5, y: 40, width: 200, height: 200))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        view.addSubview(imageView)
        
        StorageSet.shared.downloadURL(for: path, completion: {[weak self]result in
            switch result{
            case .success(let url):
                //self?.downloadImage(imageView: imageView, url: url)
                imageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("failed to get download url: \(error)")
            }
        })
        return view
    }
    /*
    func downloadImage(imageView: UIImageView, url: URL){
        imageView.sd_setImage(with: url, completed: nil)
    }
 */
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return status.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = status[indexPath.row]
        let cell = tableview.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
        cell.set(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        status[indexPath.row].handler?()
    }
}

class ProfileTableViewCell: UITableViewCell {
    static let identifier = "ProfileTableViewCell"
    public func set(with profilemodel: ProfileViewModel){
        self.textLabel?.text = profilemodel.details
        switch profilemodel.ViewModelType {
        case .info:
            self.textLabel?.textAlignment = .left
        case .logout:
            self.textLabel?.textColor = .systemBlue
            self.textLabel?.textAlignment = .center
        }
        
    }
}

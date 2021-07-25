//
//  ViewController.swift
//  mes
//
//  Created by Chun Hei Law on 7/19/21.
//

import UIKit
import FirebaseAuth

class ConversationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //view.backgroundColor = .systemTeal
        
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
}

//
//  ViewController.swift
//  mes
//
//  Created by Chun Hei Law on 7/19/21.
//

import UIKit

class ConversationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemTeal
        
    }
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        let logined = UserDefaults.standard.bool(forKey: "logined_sucessfully")
        if !logined{
            let x = LoginViewController()
            let y = UINavigationController(rootViewController: x)
            y.modalPresentationStyle = .fullScreen
            present(y, animated: false)
        }
    }

}


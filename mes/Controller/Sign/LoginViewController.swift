//
//  LoginViewController.swift
//  mes
//
//  Created by Chun Hei Law on 7/20/21.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private let scrollview: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.clipsToBounds = true
        return scrollview
    }()
    
    private let emailfield: UITextField = {
        let email = UITextField()
        email.autocapitalizationType = .none
        email.autocorrectionType = .no
        email.returnKeyType = .continue
        email.layer.cornerRadius = 11
        email.layer.borderWidth = 1
        email.layer.borderColor = UIColor.darkGray.cgColor
        email.placeholder = "Email address"
        email.leftView = UIView(frame: CGRect(x:0, y:0, width:8, height:0))
        email.leftViewMode = .always
        email.backgroundColor = .white
        return email
    }()
    
    private let passwordfield: UITextField = {
        let pw = UITextField()
        pw.autocapitalizationType = .none
        pw.autocorrectionType = .no
        pw.returnKeyType = .done
        pw.layer.cornerRadius = 11
        pw.layer.borderWidth = 1
        pw.layer.borderColor = UIColor.darkGray.cgColor
        pw.placeholder = "Password"
        pw.leftView = UIView(frame: CGRect(x:0, y:0, width:5, height:0))
        pw.leftViewMode = .always
        pw.backgroundColor = .white
        pw.isSecureTextEntry = true
        return pw
    }()
    
    private let loginbutton: UIButton = {
        let loginb = UIButton()
        loginb.setTitle("Login", for:.normal)
        loginb.backgroundColor = .white
        loginb.setTitleColor(.systemBlue, for: .normal)
        loginb.layer.cornerRadius = 11
        loginb.layer.masksToBounds = true
        loginb.titleLabel?.font = .systemFont(ofSize: 20, weight: .heavy)
        return loginb
    }()
    private let loginfButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email", "profile"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemTeal
        title = "Login"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Up",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(tapregister))
        loginbutton.addTarget(self, action: #selector(logintapped), for: .touchUpInside)
        emailfield.delegate = self
        passwordfield.delegate = self
        //for fb
        loginfButton.delegate = self
        
        view.addSubview(scrollview)
        scrollview.addSubview(emailfield)
        scrollview.addSubview(passwordfield)
        scrollview.addSubview(loginbutton)
        
        scrollview.addSubview(loginfButton)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollview.frame = view.bounds
        let size = scrollview.width/3
        emailfield.frame = CGRect(x:30,
                                  y:(size*2)+20,
                                  width:scrollview.width-60,
                                  height:40)
        passwordfield.frame = CGRect(x:30,
                                     y:emailfield.bottom+10,
                                     width:scrollview.width-60,
                                     height:40)
        loginbutton.frame = CGRect(x:30,
                                     y:passwordfield.bottom+10,
                                     width:scrollview.width-60,
                                     height:40)
        //loginfButton.center = scrollview.center
        loginfButton.frame =  CGRect(x:30,
                                     y:loginbutton.bottom+20,
                                     width:scrollview.width-60,
                                     height:40)
    }
    
    
    @objc private func logintapped(){
        
        emailfield.resignFirstResponder()
        passwordfield.resignFirstResponder()
        guard let email = emailfield.text, let password = passwordfield.text,
              !email.isEmpty, !password.isEmpty, password.count >= 4 else{
            alertloginerror()
            return
        }
        //Firebase
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self]authResult, error in
            guard let strongself = self else{
                return
            }
            guard let result = authResult, error == nil else{
                print("Failed to login ")
                return
            }
            let user = result.user
            print("Login successful, \(user)")
            strongself.navigationController?.dismiss(animated: true, completion: nil)
            
        })
    }
    func alertloginerror(){
        let alert = UIAlertController(title: "Login failed",
                                      message: "Please Try Again to log in",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dimiss",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
    @objc private func tapregister(){
        let x = RegisterViewController()
        x.title = "Create Account"
        navigationController?.pushViewController(x, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController: UITextFieldDelegate{
    func returntextfield(_ textfield: UITextField) -> Bool{
        if textfield == emailfield {
            passwordfield.becomeFirstResponder()
        }
        else if textfield == passwordfield {
            logintapped()
        }
        return true
    }
}


extension LoginViewController: LoginButtonDelegate{
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to log in facebook")
            return
        }
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: token, version: nil, httpMethod: .get)
        facebookRequest.start(completion: { _, result, error in
            guard let result = result as? [String: Any], error == nil else{
                print("failed to make facebook graph request")
                return
            }
           // print("\(result)")
            
            guard let username = result["name"] as? String, let email = result["email"] as? String else{
                print("failed to get name and email")
                return
            }
            let namecomponents = username.components(separatedBy: " ")
            guard namecomponents.count == 2 else{
                return
            }
            let firstname = namecomponents[0]
            let lastname = namecomponents[1]
            databaseset.shared.vaildateuser(with: email, completion: { exists in
                if !exists {
                    databaseset.shared.insert(with: chatuser(firstname: firstname, lastname: lastname, email: email))
                }
            })
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                guard let strongself = self else {
                    return
                }
                guard authResult != nil, error == nil else{
                    if let error = error {
                        print("Facebook credentail login failed, \(error)")
                    }
                    return
                }
                print("login successfully")
                strongself.navigationController?.dismiss(animated: true, completion: nil)
            })
        })
    }
}

//
//  RegisterViewController.swift
//  mes
//
//  Created by Chun Hei Law on 7/20/21.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    private let scrollview: UIScrollView = {
        let scrollview = UIScrollView()
        scrollview.clipsToBounds = true
        return scrollview
    }()
    private let imageview: UIImageView = {
        let imageview = UIImageView()
        let small = UIImage.SymbolConfiguration(weight: .thin)
        imageview.image = UIImage(systemName: "person", withConfiguration: small)
        imageview.tintColor = .blue
        imageview.contentMode = .scaleAspectFill
        imageview.layer.masksToBounds = true
        imageview.layer.borderWidth = 2
        imageview.layer.borderColor = UIColor.systemBlue.cgColor
        return imageview
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
    
    private let firstnamefield: UITextField = {
        let fn = UITextField()
        fn.autocapitalizationType = .none
        fn.autocorrectionType = .no
        fn.returnKeyType = .continue
        fn.layer.cornerRadius = 11
        fn.layer.borderWidth = 1
        fn.layer.borderColor = UIColor.darkGray.cgColor
        fn.placeholder = "First Name"
        fn.leftView = UIView(frame: CGRect(x:0, y:0, width:8, height:0))
        fn.leftViewMode = .always
        fn.backgroundColor = .white
        return fn
    }()
    private let lastnamefield: UITextField = {
        let ln = UITextField()
        ln.autocapitalizationType = .none
        ln.autocorrectionType = .no
        ln.returnKeyType = .continue
        ln.layer.cornerRadius = 11
        ln.layer.borderWidth = 1
        ln.layer.borderColor = UIColor.darkGray.cgColor
        ln.placeholder = "Last Name"
        ln.leftView = UIView(frame: CGRect(x:0, y:0, width:8, height:0))
        ln.leftViewMode = .always
        ln.backgroundColor = .white
        return ln
    }()
    
    
    private let registerbutton: UIButton = {
        let loginb = UIButton()
        loginb.setTitle("Register", for:.normal)
        loginb.backgroundColor = .white
        loginb.setTitleColor(.systemBlue, for: .normal)
        loginb.layer.cornerRadius = 11
        loginb.layer.masksToBounds = true
        loginb.titleLabel?.font = .systemFont(ofSize: 20, weight: .heavy)
        return loginb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemTeal
        title = "Register"
        /*
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Up",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(tapregister))
         */
        registerbutton.addTarget(self, action: #selector(registertapped), for: .touchUpInside)
        emailfield.delegate = self
        passwordfield.delegate = self
        view.addSubview(scrollview)
        scrollview.addSubview(imageview)
        scrollview.addSubview(firstnamefield)
        scrollview.addSubview(lastnamefield)
        scrollview.addSubview(emailfield)
        scrollview.addSubview(passwordfield)
        scrollview.addSubview(registerbutton)
        imageview.isUserInteractionEnabled = true
        scrollview.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(changeprofilepic))
        imageview.addGestureRecognizer(gesture)
    }
    @objc private func changeprofilepic(){
        presentphoto()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollview.frame = view.bounds
        let size = scrollview.width/3
        imageview.frame = CGRect(x:(scrollview.width - size)/2,
                                 y:size-20,
                                 width:size,
                                 height:size)
        imageview.layer.cornerRadius = imageview.width/2.0
        firstnamefield.frame = CGRect(x:30,
                                      y:imageview.bottom+30,
                                  width:scrollview.width-60,
                                  height:40)
        lastnamefield.frame = CGRect(x:30,
                                     y:firstnamefield.bottom+10,
                                  width:scrollview.width-60,
                                  height:40)
        emailfield.frame = CGRect(x:30,
                                  y:lastnamefield.bottom+10,
                                  width:scrollview.width-60,
                                  height:40)
        passwordfield.frame = CGRect(x:30,
                                     y:emailfield.bottom+10,
                                     width:scrollview.width-60,
                                     height:40)
        registerbutton.frame = CGRect(x:30,
                                     y:passwordfield.bottom+10,
                                     width:scrollview.width-60,
                                     height:40)
    }
    
    @objc private func registertapped(){
        emailfield.resignFirstResponder()
        passwordfield.resignFirstResponder()
        firstnamefield.resignFirstResponder()
        lastnamefield.resignFirstResponder()
        
        guard let firstname = firstnamefield.text, let email = emailfield.text, let password = passwordfield.text,
              !email.isEmpty, !firstname.isEmpty, !password.isEmpty, password.count >= 4 else{
            alertloginerror()
            return
        }
        //Firebase
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {authResult, error in
            guard let result = authResult, error == nil else{
                print("Error")
                return
            }
            let user = result.user
            print("User created: \(user)")
        })
    }
    func alertloginerror(){
        let alert = UIAlertController(title: "Sign Up failed",
                                      message: "Try Again to sign up a account",
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

extension RegisterViewController: UITextFieldDelegate{
    func returntextfield(_ textfield: UITextField) -> Bool{
        if textfield == emailfield {
            passwordfield.becomeFirstResponder()
        }
        else if textfield == passwordfield {
            registertapped()
        }
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func presentphoto(){
        let action = UIAlertController(title:"Profile Picture",
                                       message:"choose a method",
                                       preferredStyle: .actionSheet)
        action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        action.addAction(UIAlertAction(title: "Take a photo", style: .default,
                                       handler: { [weak self] _ in
                                        self?.accesscamera()
        }))
        action.addAction(UIAlertAction(title: "Select a photo", style: .default,
                                       handler: { [weak self] _ in
                                        self?.accessphotopicker()
        }))
        present(action,animated: true)
    }
    func accesscamera(){
        let x = UIImagePickerController()
        x.allowsEditing = true
        x.delegate = self
        x.sourceType = .camera
        present(x, animated: true)
    }
    func accessphotopicker(){
        let x = UIImagePickerController()
        x.allowsEditing = true
        x.delegate = self
        x.sourceType = .photoLibrary
        present(x, animated: true)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else{
            return
        }
        self.imageview.image = selectedImage
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

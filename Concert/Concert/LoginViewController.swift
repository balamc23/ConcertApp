//
//  LoginViewController.swift
//  Concert
//
//  Created by Kunal Shah on 4/21/18.
//  Copyright © 2018 Concert. All rights reserved.
//

import UIKit
import SpotifyLogin
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {

    var token: String? = nil
    
    var loginButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = SpotifyLoginButton(viewController: self,
                                        scopes: [.streaming,
                                                 .userReadTop,
                                                 .playlistReadPrivate,
                                                 .userLibraryRead])
        self.view.addSubview(button)
        self.loginButton = button
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loginSuccessful),
                                               name: .SpotifyLoginSuccessful,
                                               object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        loginButton?.center = self.view.center
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func loginSuccessful() {
        self.navigationController?.popViewController(animated: true)
    }

}

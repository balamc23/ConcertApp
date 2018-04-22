//
//  ViewController.swift
//  Concert
//
//  Created by Kunal Shah on 4/21/18.
//  Copyright © 2018 Concert. All rights reserved.
//

import UIKit
import SpotifyLogin
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    var authToken: String? = nil
    var nameOfUser: String? = nil
    
    
    @IBOutlet weak var makeBtn: UIButton!
    
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var logOutBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SpotifyLogin.shared.getAccessToken { [weak self] (token, error) in
            if(error == nil){
                self?.logOutBtn.alpha = 1.0
                self?.makeBtn.alpha = 1.0
                self?.joinBtn.alpha = 1.0
            }
            
            if error != nil, token == nil {
                self?.showLoginFlow()
            }
            print("^", token as String!)
            self?.authToken = token as String!
        }
        print("&", "done with token shit")
        self.getNameofUser()
    }
    
    func showLoginFlow() {
        self.performSegue(withIdentifier: "home_to_login", sender: self)
    }
    
    @IBAction func didTapLogOut(_ sender: Any) {
        print("^", authToken as String!)
        SpotifyLogin.shared.logout()
        self.logOutBtn.alpha = 0.0
        self.makeBtn.alpha = 0.0
        self.joinBtn.alpha = 0.0
        self.showLoginFlow()
    }
    
    func getNameofUser (){
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer " + authToken!
            
        ]
        
        Alamofire.request("https://api.spotify.com/v1/me", headers: headers).responseJSON { response in
            if((response.result.value) != nil) {
                let swiftyJsonVar = JSON(response.result.value!)
                self.nameOfUser = swiftyJsonVar["display_name"].string!
                print("*", self.nameOfUser as String!)
            }
        }
    }
    
    func getCodeForUser(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyz0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    @IBAction func didTapMakePlaylist(_ sender: Any) {
        
    }
    
    
    @IBAction func didTapJoinPlaylist(_ sender: Any) {
        let alertVC = UIAlertController(title: "Join a Playlist!", message: "Enter the Playlist Code", preferredStyle: .alert)
        
        alertVC.addTextField { (textField) in
            textField.placeholder = "Code..."
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default, handler: {
            (alert) -> Void in
            
            let emailTextField = alertVC.textFields![0] as UITextField
            
            print("The Code is... \(emailTextField.text!)")
        })
        
        alertVC.addAction(submitAction)
        alertVC.view.tintColor = UIColor(red: 132/255.0, green: 189/255.0, blue: 0/255.0, alpha: 1.0) 
        present(alertVC, animated: true)
    }
}


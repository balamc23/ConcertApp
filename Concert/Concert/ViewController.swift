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

    /**
    Globals
    */
    var authToken: String? = nil
    var nameOfUser: String? = nil
    var userId: String? = nil
    
    @IBOutlet weak var makeBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var logOutBtn: UIButton!
    
    /**
     Handles hiding the navigation bar before the main view appears
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.navigationController?.isNavigationBarHidden = true
    }
    
    /**
     Handles retrieving the authentication token from the Spotify API before the view is loaded
    */
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
        print("&", "retrieved token successfully")
    }
    
    /**
     Gets the name of the user and their Spotify user ID
     - Used to make playlists and join playlists
    */
    override func viewDidLoad() {
        DispatchQueue.main.async {
            self.getNameofUser()
            self.getIdofUser()
        }
    }
    
    // MARK: Utility Functions
    /**
     Performs necessary segue to go to the login flow
    */
    func showLoginFlow() {
        self.performSegue(withIdentifier: "home_to_login", sender: self)
    }
    
    /**
     Gets the name of the user based on the authentication token created above
    */
    func getNameofUser() {
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer " + authToken!
        ]
        
        let queue = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
        Alamofire.request("https://api.spotify.com/v1/me", headers: headers)
        .response(
            queue: queue,
            responseSerializer: DataRequest.jsonResponseSerializer(),
            completionHandler: { response in
                if((response.result.value) != nil) {
                    let swiftyJsonVar = JSON(response.result.value!)
                    self.nameOfUser = swiftyJsonVar["display_name"].string!
                    print("*", self.nameOfUser as String!)
                }
            }
        )
    }
    
    /**
     Gets the name of the user based on the authentication token created above
     */
    func getIdofUser() {
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer " + authToken!
        ]
        
        let queue = DispatchQueue(label: "com.cnoon.response-queue", qos: .utility, attributes: [.concurrent])
        Alamofire.request("https://api.spotify.com/v1/me", headers: headers)
        .response(
            queue: queue,
            responseSerializer: DataRequest.jsonResponseSerializer(),
            completionHandler: { response in
                if((response.result.value) != nil) {
                    let swiftyJsonVar = JSON(response.result.value!)
                    self.userId = swiftyJsonVar["id"].string!
                    print("*", self.userId as String!)
                }
            }
        )
    }
    
    func makeNewPlaylist(name: String) {
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer " + authToken!
        ]
        let parameters: [String: Any] = [
            "name" : name,
            "collaborative" : true,
            "paylist-modify": true
        ]
        
        let url = "https://api.spotify.com/v1/users/" + userId! + "/playlists"
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                print(response)
        }
    }
    /**
     Makes random code to enter for playlist creation
    */
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
    
    // MARK: Action Functions
    
    /**
     Handles the creation of a playlist
    */
    @IBAction func didTapMakePlaylist(_ sender: Any) {
        let alertVC = UIAlertController(title: "Make a Playlist!", message: "Enter your Playlist Name", preferredStyle: .alert)
        
        alertVC.addTextField { (textField) in
            textField.placeholder = "Name..."
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default, handler: {
            (alert) -> Void in
            
            let playlistName = alertVC.textFields![0] as UITextField
            print("The Playlist Name is... \(playlistName.text!)")
            self.makeNewPlaylist(name: playlistName.text!)
        })
        
        alertVC.addAction(submitAction)
        alertVC.view.tintColor = UIColor(red: 132/255.0, green: 189/255.0, blue: 0/255.0, alpha: 1.0)
        present(alertVC, animated: true)
        
    }
    
    /**
     Handles joining a playlist
     */
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
    
    /**
     Handles logging out of the current Spotify account
     */
    @IBAction func didTapLogOut(_ sender: Any) {
        print("^", authToken as String!)
        SpotifyLogin.shared.logout()
        self.logOutBtn.alpha = 0.0
        self.makeBtn.alpha = 0.0
        self.joinBtn.alpha = 0.0
        self.showLoginFlow()
    }
}


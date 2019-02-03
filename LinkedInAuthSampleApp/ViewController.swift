//
//  ViewController.swift
//  LinkedInAuthSampleApp
//
//  Created by Gabriel Vincent on 03/02/19.
//  Copyright © 2019 Gabriel Vincent. All rights reserved.
//

import UIKit
import LinkedInAuth

class ViewController: UIViewController {
    
    @IBOutlet var authenticationButton:UIButton!
    @IBOutlet var nameLabel:UILabel!
    @IBOutlet var headlineLabel:UILabel!
    @IBOutlet var summaryTextView:UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    // MARK: - Implementation
    
    func updateUI(WithProfileData profileData:[AnyHashable:Any]) { DispatchQueue.main.async {
    
        self.authenticationButton.isHidden = true
        
        if let firstName = profileData["firstName"] as? String,
            let lastName = profileData["lastName"] as? String {
            
            self.nameLabel.text = "Logged in as \(firstName) \(lastName)"
        }
        
        if let headline = profileData["headline"] as? String {
            
            self.headlineLabel.text = headline
        }
        
        if let summary = profileData["summary"] as? String {
            
            self.summaryTextView.text = summary
        }
    }}
    
    func didGetBasicProfileData(withJSONData jsonData:Data) {
        
        do {
            
            if let profileData = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [AnyHashable:Any] {
                
                print("Did get basic profile data: \(profileData.debugDescription)")
                updateUI(WithProfileData: profileData)
            }
        }
        catch let error {
            
            print("Couldn't parse data to JSON. Error: \(error.localizedDescription)")
        }
    }
    
    func getBasicProfileData(WithAccessToken accessToken:String) {
        
        guard let url = URL(string: "https://api.linkedin.com/v1/people/~:(id,first-name,last-name,picture-urls::(original),location,headline,industry,summary,specialties,positions,email-address)?format=json") else {
            
            print("[SignUpViewController]: Malformed URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard data != nil, response != nil, error == nil else {
                
                print("Couldn't get basic profile data. Error: \(error!.localizedDescription)")
                return
            }
            
            self.didGetBasicProfileData(withJSONData: data!)
        }
        task.resume()
    }
    
    // MARK: - IBAtions
    
    @IBAction func handleLinkedInAuthenticationButtonTap() {
        
        let liAuthConfig = LinkedInAuthConfiguration(WithClientID: "789i307bwx6ct7",
                                                     clientSecret: "5l9FlQQy11VRCKvU",
                                                     redirectURI: "https://arcane-shore-56552.herokuapp.com/",
                                                     scope: [.BasicProfile, .EmailAddress])
        
        LinkedInAuth.manager.authenticate(WithConfiguration: liAuthConfig, success: { (accessToken) in
            
            self.getBasicProfileData(WithAccessToken: accessToken)
            
        }) { (error) in
            
            print("Authentication failed. Error: \(error.localizedDescription)")
        }
    }
}

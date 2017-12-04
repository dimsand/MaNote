//
//  MailViewController.swift
//  MaNote
//
//  Created by admin on 04/12/2017.
//  Copyright © 2017 admin. All rights reserved.
//

import UIKit
import MessageUI

class MailViewController: UIViewController, MFMailComposeViewControllerDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }*/
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients(["address@example.com"])
        composeVC.setSubject("Note de frais")
        composeVC.setMessageBody("Bonjour, voici ma note de frais !", isHTML: false)
        
        // Present the view controller modally.
        
        //self.present(composeVC, animated: true, completion: nil)
        //self.presentViewController(composeVC, animated: true, completion: nil)
        
        func mailComposeController(controller: MFMailComposeViewController,
                                   didFinishWithResult result: MFMailComposeResult, error: NSError?) {
            // Check the result or perform other tasks.
            
            // Dismiss the mail compose view controller.
            controller.dismiss(animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

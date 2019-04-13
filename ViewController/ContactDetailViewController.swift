//
//  ContactDetailViewController.swift
//  Contacts2
//
//  Created by Colin Smith on 4/12/19.
//  Copyright © 2019 Colin Smith. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var phoneLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    
    var contact: Contact?

    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = contact?.name
        phoneLabel.text = contact?.phone
        emailLabel.text = contact?.email
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nameLabel.text = contact?.name
        phoneLabel.text = contact?.phone
        emailLabel.text = contact?.email
        
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        guard let contact = contact,
        let name = nameLabel.text,
        let phone = phoneLabel.text,
        let email = emailLabel.text else {return}
        ContactController.shared.update(nameToUpdate: name, phoneToUpdate: phone, emailToUpdate: email, contact: contact) { (success) in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                
            }
        }
    }
}

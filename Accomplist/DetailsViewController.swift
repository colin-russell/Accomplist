//
//  DetailsViewController.swift
//  Accomplist
//
//  Created by Colin on 2018-11-27.
//  Copyright © 2018 Colin Russell. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, UITextViewDelegate {
    
    
    // MARK: Properties
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var detailsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsTextView.delegate = self
    }
    
    // MARK: UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    // MARK: Actions
    
    @IBAction func reminderSwitchToggled(_ sender: UISwitch) {
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

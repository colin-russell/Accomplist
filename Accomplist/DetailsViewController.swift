//
//  DetailsViewController.swift
//  Accomplist
//
//  Created by Colin on 2018-11-27.
//  Copyright © 2018 Colin Russell. All rights reserved.
//

import UIKit

protocol DetailsViewControllerDelegate: AnyObject {
    func didFinishEditingToDo(toDo: ToDo)
}

class DetailsViewController: UIViewController, UITextViewDelegate {
    
    // MARK: Properties
    
    var toDo = ToDo()
    var delegate: DetailsViewControllerDelegate?
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var reminderSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsTextView.delegate = self
        detailsTextView.text = toDo.toDoDescription
        reminderSwitch.isOn = toDo.isAlertSet
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let hmv = segue.destination as? HomeViewController {
            hmv.currentToDos[hmv.currentIndex] = toDo
            hmv.updateToDoList()
            hmv.listTableView.reloadData()
        }
    }
    
    // MARK: UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            
            toDo.toDoDescription = textView.text
            
            return false
        }
        return true
    }
    
    // MARK: Actions
    
    @IBAction func reminderSwitchToggled(_ sender: UISwitch) {
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        delegate?.didFinishEditingToDo(toDo: toDo)
        dismiss(animated: true, completion: nil)
    }
    
}

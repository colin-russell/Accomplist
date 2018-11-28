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
        datePicker.date = toDo.alertDate
        datePicker.minimumDate = Date().addingTimeInterval(120)
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
            return false
        }
        return true
    }
    
    func setReminder() {
        if reminderSwitch.isOn{
            if datePicker.date < Date() {
                let dateAlert = UIAlertController(title: "Error", message: "Please select a future time", preferredStyle: .alert)
                dateAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                present(dateAlert, animated: true)
                reminderSwitch.isOn = false
                toDo.isAlertSet = false
            } else {
                toDo.alertDate = datePicker.date
                toDo.isAlertSet = true
            }
        }
    }
    // MARK: Actions
    
    @IBAction func reminderSwitchToggled(_ sender: UISwitch) {
        setReminder()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        toDo.toDoDescription = detailsTextView.text
        setReminder()
        delegate?.didFinishEditingToDo(toDo: toDo)
        dismiss(animated: true, completion: nil)
    }
    
}

//
//  ViewController.swift
//  Accomplist
//
//  Created by Colin on 2018-11-26.
//  Copyright © 2018 Colin Russell. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    // MARK: Properties
    
    let menuTableView = UITableView()
    let mWMultiplier: CGFloat = 0.4
    var toDoLists = [ToDoList]()
    
    var appDelegate = AppDelegate()
    var context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var listTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        setupMenu()
        //        createToDoList()
        fetchToDoList()
        removeToDoList(list: toDoLists.first!)
    }
    
    func setupMenu() {
        menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: "listCell")
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.backgroundColor = UIColor.darkGray
        menuTableView.layer.borderColor = UIColor.lightGray.cgColor
        menuTableView.layer.borderWidth = 2.0
        menuTableView.frame = CGRect(x: 0, y: 0, width: view.frame.width * self.mWMultiplier, height: view.frame.height)
        
        view.insertSubview(menuTableView, belowSubview: backView)
    }
    
    func showMenu() {
        let oldFrame = backView.frame
        
        UIView.animate(withDuration: 0.5) {
            self.backView.frame = CGRect(x: oldFrame.origin.x + (oldFrame.width * self.mWMultiplier), y: oldFrame.origin.y, width: oldFrame.width, height: oldFrame.height)
        }
        
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(recognizer:))))
    }
    
    func hideMenu() {
        let oldFrame = backView.frame
        
        UIView.animate(withDuration: 0.5) {
            self.backView.frame = CGRect(x: oldFrame.origin.x - (oldFrame.width * self.mWMultiplier), y: oldFrame.origin.y, width: oldFrame.width, height: oldFrame.height)
        }
        for recognizer in backView.gestureRecognizers ?? [] {
            backView.removeGestureRecognizer(recognizer)
        }
    }
    
    func showTextViewAlert() {
        let textAlertController = UIAlertController(title: "New To Do", message: "", preferredStyle: .alert)
        textAlertController.addTextField { (textField) in
            textField.placeholder = "Task/Reminder Details"
        }
        let okAlert = UIAlertAction(title: "Ok", style: .default) { (_) in
            guard let textField = textAlertController.textFields?.first else { return }
            print("details text: \(String(describing: textField.text))")
        }
        
        textAlertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        textAlertController.addAction(okAlert)
        present(textAlertController, animated: true)
    }
    
    func createToDoList() {
        //        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "ToDoList", in: context)
        let newToDoList = NSManagedObject(entity: entity!, insertInto: context)
        
        
        newToDoList.setValue("To Do", forKey: "name")
        newToDoList.setValue("blue", forKey: "listColour")
        newToDoList.setValue(Data(), forKey: "toDoData")
        
        do {
            try context.save()
            
        } catch {
            print("Failed saving")
        }
    }
    
    func fetchToDoList() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDoList")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                //                print(data.value(forKey: "name") as! String)
                guard let toDoList = data as? ToDoList else { return }
                self.toDoLists.append(toDoList)
            }
            
        } catch {
            print("Failed")
        }
    }
    
    func removeToDoList(list: ToDoList) {
        context.delete(list)
        
        do {
            try context.save()
            
        } catch {
            print("Failed saving")
        }
        
    }
    
    // MARK: Actions
    
    @objc func viewTapped(recognizer: UITapGestureRecognizer) {
        hideMenu()
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        print("menu button tapped")
        
        
        // show menu
        if backView.frame.origin == CGPoint.zero {
            showMenu()
            
        } else { // hide menu
            hideMenu()
        }
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        print("edit")
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        print("add")
        
        
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == listTableView  {
            return 4
        } else {
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if tableView == listTableView {
            cell = listTableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath)
        } else {
            cell = menuTableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        }
        
        cell.textLabel?.text = "Number: \(indexPath)"
        
        return cell
    }
}


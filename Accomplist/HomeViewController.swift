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
    var currentToDos = [ToDo]()
    
    var appDelegate = AppDelegate()
    var context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var listTableView: UITableView!
    
    // MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        setupMenu()
        
        fetchToDoLists()
        menuTableView.reloadData()
    }
    
    func setupMenu() {
        let listLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width * self.mWMultiplier, height: ((view.frame.height / 3) - 100)))
        listLabel.text = "Lists."
        listLabel.textAlignment = .center
        listLabel.font = UIFont(name: "LouisGeorgeCafe-Bold", size: 34)
        listLabel.backgroundColor = UIColor.lightGray
        
        let createListButton = UIButton(type: .system)
        createListButton.frame = CGRect(x: 0, y: ((view.frame.height / 3) - 100), width: view.frame.width * self.mWMultiplier, height: 100)
        createListButton.setTitle("+", for: .normal)
        createListButton.backgroundColor = UIColor.black
        createListButton.tintColor = UIColor.white
        createListButton.titleLabel?.font = UIFont(name: createListButton.titleLabel!.font.fontName, size: 50)
        
        menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: "listCell")
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.frame = CGRect(x: 0, y: view.frame.height / 3, width: view.frame.width * self.mWMultiplier, height: view.frame.height * (2 / 3))
        
        view.insertSubview(createListButton, belowSubview: backView)
        view.insertSubview(listLabel, belowSubview: backView)
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
            //            print("details text: \(String(describing: textField.text))")
            let toDo = ToDo()
            toDo.toDoDescription = textField.text ?? "NIL"
            self.currentToDos.append(toDo)
            self.listTableView.reloadData()
        }
        
        textAlertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        textAlertController.addAction(okAlert)
        present(textAlertController, animated: true)
    }
    
    func createToDoList(name: String, toDos: [ToDo]) {
        
        let entity = NSEntityDescription.entity(forEntityName: "ToDoList", in: context)
        let newToDoList = NSManagedObject(entity: entity!, insertInto: context)
        var toDoData = Data()
        
        do {
            try  toDoData = NSKeyedArchiver.archivedData(withRootObject: toDos, requiringSecureCoding: false)
        } catch  {
            print("Failed converting array to Data")
        }
        
        newToDoList.setValue(name, forKey: "name")
        //        newToDoList.setValue(colour.htmlRGBaColor, forKey: "listColour")
        newToDoList.setValue(toDoData, forKey: "toDoData")
        
        do {
            try context.save()
            
        } catch {
            print("Failed saving")
        }
    }
    
    func fetchToDoLists() {
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
//        createToDoList(name: "numbers", toDos: currentToDos)
        if backView.frame.origin == CGPoint.zero {
            showMenu()
        } else {
            hideMenu()
        }
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        print("edit")
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        print("add")
        
        showTextViewAlert()
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == listTableView  {
            return currentToDos.count
        } else {
            return toDoLists.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if tableView == listTableView {
            cell = listTableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath)
            cell.textLabel?.text = "\(currentToDos[indexPath.row].toDoDescription)"
        } else {
            cell = menuTableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
            cell.textLabel?.text = "\(toDoLists[indexPath.row].name ?? "No Name")"
        }
        
        return cell
    }
}


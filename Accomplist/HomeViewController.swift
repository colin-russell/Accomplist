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
    var currentIndex = 0
    
    var appDelegate = AppDelegate()
    var context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var listTitleLabel: UILabel!
    
    // MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        setupMenu()
        
        fetchToDoLists()
        updateHome()
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
    
    func showNewListItemAlert() {
        let textAlertController = UIAlertController(title: "New List Item", message: "", preferredStyle: .alert)
        textAlertController.addTextField { (textField) in
            textField.placeholder = "Task/Reminder Details"
        }
        let okAlert = UIAlertAction(title: "Ok", style: .default) { (_) in
            guard let textField = textAlertController.textFields?.first else { return }
            //            print("details text: \(String(describing: textField.text))")
            let toDo = ToDo()
            toDo.toDoDescription = textField.text ?? "NIL"
            self.currentToDos.append(toDo)
            self.updateToDoList()
            self.listTableView.reloadData()
        }
        
        textAlertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        textAlertController.addAction(okAlert)
        present(textAlertController, animated: true)
    }
    
    
    func createToDoList() {
        let textAlertController = UIAlertController(title: "New List", message: "", preferredStyle: .alert)
        textAlertController.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        let okAlert = UIAlertAction(title: "Ok", style: .default) { (_) in
            guard let textField = textAlertController.textFields?.first else { return }
            
            let toDoList = ToDoList(context: self.context)
            toDoList.name = textField.text
            
            let entity = NSEntityDescription.entity(forEntityName: "ToDoList", in: self.context)
            let newToDoList = NSManagedObject(entity: entity!, insertInto: self.context)
            var toDoData = Data()
            
            do {
                try  toDoData = NSKeyedArchiver.archivedData(withRootObject: self.currentToDos, requiringSecureCoding: false)
            } catch  {
                print("Failed converting array to Data")
            }
            
            toDoList.toDoData = toDoData
            self.toDoLists.append(toDoList)
            
            newToDoList.setValue(toDoList.name, forKey: "name")
            //        newToDoList.setValue(colour.htmlRGBaColor, forKey: "listColour")
            newToDoList.setValue(toDoData, forKey: "toDoData")
            
            do {
                try self.context.save()
                
            } catch {
                print("Failed saving")
            }
            
            self.fetchToDoLists()
        }
        
        textAlertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        textAlertController.addAction(okAlert)
        present(textAlertController, animated: true)

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
    
    func updateToDoList() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDoList")
        var toDoData = Data()
        
        do {
            try  toDoData = NSKeyedArchiver.archivedData(withRootObject: currentToDos, requiringSecureCoding: false)
        } catch  {
            print("Failed converting array to Data")
        }
        
        do {
            guard let results = try context.fetch(fetchRequest) as? [NSManagedObject] else { return }
            if results.count != 0 { // Atleast one was returned
                
                // In my case, I only updated the first item in results
                results[currentIndex].setValue(toDoData, forKey: "toDoData")
            }
        } catch {
            print("Fetch Failed: \(error)")
        }
        
        do {
            try context.save()
        }
        catch {
            print("Saving Core Data Failed: \(error)")
        }
    }
    
    func updateHome() {
        if currentToDos.count > 0 {
            do {
                try currentToDos = NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(toDoLists[0].toDoData!) as! [ToDo]
            } catch {
                print("Failed unarchiving")
            }
            listTitleLabel.text = toDoLists[0].name
        } else {
            createToDoList()
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
//        createToDoList()
        if backView.frame.origin == CGPoint.zero {
            showMenu()
        } else {
            hideMenu()
        }
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        listTableView.setEditing(!listTableView.isEditing, animated: true)
        
        if listTableView.isEditing {
            sender.setTitle("Done", for: .normal)
        } else {
            sender.setTitle("Edit", for: .normal)
        }
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        print("add")
        
        showNewListItemAlert()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == menuTableView {
            var toDos = [ToDo]()
            currentIndex = indexPath.row
            
            do {
                try toDos = NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(toDoLists[indexPath.row].toDoData!) as! [ToDo]
            } catch {
                print("Failed unarchiving")
            }
            
            currentToDos = toDos
            listTitleLabel.text = toDoLists[indexPath.row].name
            listTableView.reloadData()
            hideMenu()
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            print("delete cell")
            self.currentToDos.remove(at: indexPath.row)
            self.updateToDoList()
            self.listTableView.reloadData()
        }
        deleteAction.backgroundColor = .red
        return [deleteAction]
    }
}


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
    let mWMultiplier: CGFloat = 0.6
    var toDoLists = [ToDoList]()
    var currentToDos = [ToDo]()
    var currentToDoIndex = 0
    var currentListIndex = 0
    
    var appDelegate = AppDelegate()
    var context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var listTitleLabel: UILabel!
    @IBOutlet weak var editToDoButton: UIButton!
    @IBOutlet weak var addToDoButton: UIButton!
    @IBOutlet weak var welcomeTextView: UITextView!
    
    // MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        setupMenu()
        
        fetchToDoLists()
        checkForToDoLists()
        menuTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? DetailsViewController {
            dvc.toDo = currentToDos[currentToDoIndex]
            dvc.delegate = self
        }
    }
    
    func setupMenu() {
        let listLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width * self.mWMultiplier, height: ((view.frame.height / 3) - 100)))
        listLabel.text = "Lists."
        listLabel.textAlignment = .center
        listLabel.font = UIFont(name: "LouisGeorgeCafe-Bold", size: 34)
        listLabel.backgroundColor = UIColor.lightGray
        
        let editListButton = UIButton(type: .system)
        editListButton.frame = CGRect(x: 0, y: ((view.frame.height / 3) - 100), width: (view.frame.width * self.mWMultiplier) / 2, height: 100)
        editListButton.setTitle("Edit", for: .normal)
        editListButton.backgroundColor = UIColor.darkGray
        editListButton.tintColor = UIColor.white
        editListButton.titleLabel?.font = UIFont(name: "LouisGeorgeCafe", size: 25)
        editListButton.addTarget(self, action:#selector(editListButtonTapped(sender:)), for: .touchUpInside)
        
        let createListButton = UIButton(type: .system)
        createListButton.frame = CGRect(x: editListButton.frame.width, y: ((view.frame.height / 3) - 100), width: (view.frame.width * self.mWMultiplier) / 2, height: 100)
        createListButton.setTitle("+", for: .normal)
        createListButton.backgroundColor = UIColor.black
        createListButton.tintColor = UIColor.white
        createListButton.titleLabel?.font = UIFont(name: "LouisGeorgeCafe-Bold", size: 34)
        
        createListButton.addTarget(self, action:#selector(createListButtonTapped), for: .touchUpInside)
        
        
        
        menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: "listCell")
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.frame = CGRect(x: 0, y: view.frame.height / 3, width: view.frame.width * self.mWMultiplier, height: view.frame.height * (2 / 3))
        
        view.insertSubview(editListButton, belowSubview: backView)
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
        if backView.frame.origin != CGPoint.zero {
            
            let oldFrame = backView.frame
            
            UIView.animate(withDuration: 0.5) {
                self.backView.frame = CGRect(x: oldFrame.origin.x - (oldFrame.width * self.mWMultiplier), y: oldFrame.origin.y, width: oldFrame.width, height: oldFrame.height)
            }
            for recognizer in backView.gestureRecognizers ?? [] {
                backView.removeGestureRecognizer(recognizer)
            }
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
    
    func addToDoList(name: String) {
        let entity = NSEntityDescription.entity(forEntityName: "ToDoList", in: context)
        let newToDoList = NSManagedObject(entity: entity!, insertInto: context)
        
        var toDoData = Data()
        
        do {
            try  toDoData = NSKeyedArchiver.archivedData(withRootObject: [ToDo](), requiringSecureCoding: false)
        } catch  {
            print("Failed converting array to Data")
        }
        
        newToDoList.setValue(name, forKey: "name")
        
        newToDoList.setValue(toDoData, forKey: "toDoData")
        
        do {
            try context.save()
            
        } catch {
            print("Failed saving")
        }
    }
    
    func showNewToDoListAlert() {
        let textAlertController = UIAlertController(title: "New List", message: "", preferredStyle: .alert)
        textAlertController.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        let okAlert = UIAlertAction(title: "Ok", style: .default) { (_) in
            guard let textField = textAlertController.textFields?.first else { return }
            
            self.addToDoList(name: textField.text!)
            self.fetchToDoLists()
            self.menuTableView.reloadData()
            self.checkForToDoLists()
        }
        
        textAlertController.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        textAlertController.addAction(okAlert)
        present(textAlertController, animated: true)
        
    }
    
    func unarchiveToDos() {
        var toDos = [ToDo]()
        
        do {
            try toDos = NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(toDoLists[currentListIndex].toDoData!) as! [ToDo]
        } catch {
            print("Failed unarchiving")
        }
        
        currentToDos = toDos
        listTitleLabel.text = toDoLists[currentListIndex].name
        listTableView.reloadData()
    }
    
    func fetchToDoLists() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDoList")
        request.returnsObjectsAsFaults = false
        toDoLists = [ToDoList]()
        
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
                results[currentListIndex].setValue(toDoData, forKey: "toDoData")
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
    
    func checkForToDoLists() {
        if self.toDoLists.count > 0 {
            editToDoButton.isHidden = false
            listTableView.isHidden = false
            addToDoButton.isHidden = false
            
            welcomeTextView.isHidden = true
            currentListIndex = 0
            unarchiveToDos()
        } else {
            listTitleLabel.text = ""
            editToDoButton.isHidden = true
            listTableView.isHidden = true
            addToDoButton.isHidden = true
            welcomeTextView.isHidden = false
        }
    }
    
    func removeToDoList(list: ToDoList) {
        context.delete(list)
        
        do {
            try context.save()
            
        } catch {
            print("Failed saving")
        }
        
        fetchToDoLists()
        menuTableView.reloadData()
        checkForToDoLists()
    }
    
    // MARK: Actions
    
    @objc func viewTapped(recognizer: UITapGestureRecognizer) {
        hideMenu()
    }
    
    @objc func createListButtonTapped() {
        showNewToDoListAlert()
    }
    
    @objc func editListButtonTapped(sender: UIButton) {
        menuTableView.setEditing(!menuTableView.isEditing, animated: true)
        
        if menuTableView.isEditing {
            sender.setTitle("Done", for: .normal)
        } else {
            sender.setTitle("Edit", for: .normal)
        }
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        
        //        createToDoList()
        if backView.frame.origin == CGPoint.zero {
            showMenu()
        } else {
            hideMenu()
        }
    }
    
    
    @IBAction func editToDoButtonTapped(_ sender: UIButton) {
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
            cell.textLabel?.font = UIFont(name: "LouisGeorgeCafe", size: 25)
            cell.textLabel?.text = "\(currentToDos[indexPath.row].toDoDescription)"
            
            let toDo = currentToDos[indexPath.row]
            let checkmark: UITableViewCell.AccessoryType = toDo.isCompleted ? .checkmark : .none
            cell.accessoryType = checkmark
            cell.editingAccessoryType = .detailButton
        } else {
            cell = menuTableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
            cell.textLabel?.font = UIFont(name: "LouisGeorgeCafe", size: 25)
            cell.textLabel?.text = "\(toDoLists[indexPath.row].name ?? "No Name")"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == menuTableView {
            currentListIndex = indexPath.row
            
            unarchiveToDos()
            listTableView.reloadData()
            hideMenu()
        } else if tableView == listTableView {
            currentToDos[indexPath.row].isCompleted = currentToDos[indexPath.row].isCompleted ? false : true
            
            updateToDoList()
            listTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if tableView == listTableView {
            let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
                
                self.currentToDos.remove(at: indexPath.row)
                self.updateToDoList()
                self.listTableView.reloadData()
            }
            deleteAction.backgroundColor = .red
            return [deleteAction]
        } else {
            let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
                
                self.removeToDoList(list: self.toDoLists[indexPath.row])
            }
            deleteAction.backgroundColor = .red
            return [deleteAction]
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        currentToDoIndex = indexPath.row
        performSegue(withIdentifier: "detailsSegue", sender: self)
    }
}

extension HomeViewController: DetailsViewControllerDelegate {
    func didFinishEditingToDo(toDo: ToDo) {
        
        currentToDos[currentToDoIndex] = toDo
        updateToDoList()
        listTableView.reloadData()
    }
}


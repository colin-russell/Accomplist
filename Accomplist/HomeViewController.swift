//
//  ViewController.swift
//  Accomplist
//
//  Created by Colin on 2018-11-26.
//  Copyright © 2018 Colin Russell. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let menuTableView = UITableView()
    let mWMultiplier: CGFloat = 0.4
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var listTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMenu()
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
    
    // MARK: UITableViewDelegate
    
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


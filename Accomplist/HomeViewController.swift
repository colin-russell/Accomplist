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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupMenu()
    }
    
    func setupMenu() {
        menuTableView.frame = CGRect(x: -(view.frame.width * mWMultiplier), y: 0, width: view.frame.width * mWMultiplier, height: view.frame.height)
        menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: "listCell")
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.backgroundColor = UIColor.darkGray
        menuTableView.layer.borderColor = UIColor.lightGray.cgColor
        menuTableView.layer.borderWidth = 2.0
        view.addSubview(menuTableView)
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
        
    }
    
    // MARK: Actions
    
    @objc func viewTapped(recognizer: UITapGestureRecognizer) {
        let oldFrame = view.frame
        
        UIView.animate(withDuration: 0.5) {
            self.view.frame = CGRect(x: oldFrame.origin.x - (oldFrame.width * self.mWMultiplier), y: oldFrame.origin.y, width: oldFrame.width, height: oldFrame.height)
        }
        for recognizer in view.gestureRecognizers ?? [] {
            view.removeGestureRecognizer(recognizer)
        }
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        print("menu button tapped")
        let oldFrame = view.frame
        var newFrame = CGRect()
        
        // show menu
        if view.frame.origin == CGPoint.zero {
            newFrame = CGRect(x: oldFrame.origin.x + (oldFrame.width * mWMultiplier), y: oldFrame.origin.y, width: oldFrame.width, height: oldFrame.height)
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(recognizer:))))
        } else { // hide menu
            newFrame = CGRect(x: oldFrame.origin.x - (oldFrame.width * mWMultiplier), y: oldFrame.origin.y, width: oldFrame.width, height: oldFrame.height)
            for recognizer in view.gestureRecognizers ?? [] {
                view.removeGestureRecognizer(recognizer)
            }
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.frame = newFrame
        }
        
    }
}


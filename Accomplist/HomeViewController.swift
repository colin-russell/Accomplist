//
//  ViewController.swift
//  Accomplist
//
//  Created by Colin on 2018-11-26.
//  Copyright © 2018 Colin Russell. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    
    @objc func viewTapped(recognizer: UITapGestureRecognizer) {
        let oldFrame = view.frame
        
        UIView.animate(withDuration: 0.5) {
            self.view.frame = CGRect(x: oldFrame.origin.x - (oldFrame.width*0.6), y: oldFrame.origin.y, width: oldFrame.width, height: oldFrame.height)
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
            newFrame = CGRect(x: oldFrame.origin.x + (oldFrame.width*0.6), y: oldFrame.origin.y, width: oldFrame.width, height: oldFrame.height)
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(recognizer:))))
        } else { // hide menu
            newFrame = CGRect(x: oldFrame.origin.x - (oldFrame.width*0.6), y: oldFrame.origin.y, width: oldFrame.width, height: oldFrame.height)
            for recognizer in view.gestureRecognizers ?? [] {
                view.removeGestureRecognizer(recognizer)
            }
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.frame = newFrame
        }
        
    }
}


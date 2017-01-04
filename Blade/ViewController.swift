//
//  ViewController.swift
//  Blade
//
//  Created by Trevor Stevenson on 10/29/16.
//  Copyright © 2016 TStevensonApps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var swordSpear: UIImageView!
    @IBOutlet weak var huntedLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationController?.isNavigationBarHidden = true
    
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        swordSpear.alpha = 0.0
        huntedLabel.alpha = 0.0
        playButton.alpha = 0.0
        
        UIView.animate(withDuration: 1.0, animations: {
            
            self.huntedLabel.alpha = 1.0
            
        }) { (isCompleted) in
            
            
            UIView.animate(withDuration: 2.0, animations: {
                
                self.swordSpear.alpha = 1.0
                
            }) { (isCompleted2) in
                
                
                UIView.animate(withDuration: 1.0, animations: {
                    
                    self.playButton.alpha = 1.0
                    
                })
            }
        }
    }
}


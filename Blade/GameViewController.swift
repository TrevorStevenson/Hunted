//
//  GameViewController.swift
//  Blade
//
//  Created by Trevor Stevenson on 10/29/16.
//  Copyright © 2016 TStevensonApps. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var moveLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let boardRect = CGRect(x: 10, y: 40, width: self.view.frame.size.width - 20, height: self.view.frame.size.width - 20)
        
        let gameBoard = Board(Bframe: boardRect, rows: 5, columns: 5, gvc: self)
        
        self.view.addSubview(gameBoard)
        
    }
    
    @IBAction func makeMove(sender: UIButton)
    {
        print(sender.tag)
    }
    
    @IBAction func quit(_ sender: AnyObject) {
        
        _ = self.navigationController?.popToRootViewController(animated: false)
    }
}

//
//  Board.swift
//  Blade
//
//  Created by Trevor Stevenson on 10/29/16.
//  Copyright © 2016 TStevensonApps. All rights reserved.
//

import UIKit

class Board: UIView {
    
    var numRows = 5
    var numCols = 5
    var width : CGFloat = 4.0
    var GVC = GameViewController()
    
    var colSpacing : CGFloat = 0.0
    var rowSpacing : CGFloat = 0.0
    
    var buttons : [UIButton] = []
    var eliminated: [Int] = []
    
    var currentKnight = UIImageView()
    var currentGunman = UIImageView()
    var kRow = 4
    var kCol = 0
    var gRow = 0
    var gCol = 4
    var turn = 1
    
    var knightTeleports = 3
    var gunmanTeleports = 3
    
    var isDeletedArray: [Bool] = []
    
    var itIsKnightsMove = true
    var itIsGunmansMove = false
    var gunmanIsInCheck = false
    var knightIsInCheck = false
    var gunmanCanMove = true
    var knightCanMove = true
    
    var rand = 0
    
    
    init(Bframe: CGRect, rows: Int, columns: Int, gvc: GameViewController) {
        
        super.init(frame: Bframe)
        
        numRows = rows
        numCols = columns
        GVC = gvc
        let woodView = UIImageView(image: #imageLiteral(resourceName: "wood-3"))
        woodView.frame = CGRect(x: 5, y: 5, width: self.frame.width - 10, height: self.frame.height - 10)
        self.addSubview(woodView)
        self.sendSubview(toBack: woodView)
        
        colSpacing = self.frame.width / CGFloat(numCols)
        rowSpacing = self.frame.height / CGFloat(numRows)
        
        drawKnight(row: CGFloat(numRows) - 1, col: 0)
        drawGunman(row: 0, col: CGFloat(numCols) - 1)
        
        self.backgroundColor = UIColor.clear
                
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let borderLayer = CAShapeLayer()
        let border = UIBezierPath(rect: CGRect(origin: CGPoint(x: 5, y: 5), size: CGSize(width: self.frame.width - 10, height: self.frame.height - 10)))
        borderLayer.lineWidth = width
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.path = border.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(borderLayer)
        
        for i in 1...numCols - 1
        {
            let index = CGFloat(i)
            let colLayer = CAShapeLayer()
            let colPath = UIBezierPath()
            colPath.move(to: CGPoint(x: index * colSpacing, y: 5))
            colPath.addLine(to: CGPoint(x: index * colSpacing, y: self.frame.size.height - 5))
            colLayer.path = colPath.cgPath
            colLayer.lineWidth = width
            colLayer.strokeColor = UIColor.white.cgColor
            colLayer.fillColor = UIColor.clear.cgColor
            self.layer.addSublayer(colLayer)
        }
        
        for i in 1...numRows - 1
        {
            let index = CGFloat(i)
            let rowLayer = CAShapeLayer()
            let rowPath = UIBezierPath()
            rowPath.move(to: CGPoint(x: 5, y: index * rowSpacing))
            rowPath.addLine(to: CGPoint(x: self.frame.size.width - 5, y: index * rowSpacing))
            rowLayer.path = rowPath.cgPath
            rowLayer.lineWidth = width
            rowLayer.strokeColor = UIColor.white.cgColor
            rowLayer.fillColor = UIColor.clear.cgColor
            self.layer.addSublayer(rowLayer)
        }
        
        var currentIndex = 0
        
        for rowIndex in 1...numRows
        {
            for columnIndex in 1...numCols
            {
                let button = UIButton(frame: CGRect(x: CGFloat(rowIndex - 1) * (colSpacing), y: CGFloat(columnIndex - 1) * (rowSpacing), width: CGFloat(rowSpacing), height: CGFloat(colSpacing)))
                button.tag = currentIndex
                button.addTarget(self, action: #selector(Board.makeMove(sender:)), for: .touchUpInside)
                self.addSubview(button)
                buttons.append(button)
                
                currentIndex += 1
            }
        }
    }
    
    func drawKnight(row: CGFloat, col: CGFloat)
    {
        currentKnight.removeFromSuperview()
        let knightView = UIImageView(image: #imageLiteral(resourceName: "knight"))
        knightView.frame = CGRect(x: col * colSpacing + 10, y: row * rowSpacing + 10, width: rowSpacing - 20, height: colSpacing - 20)
        self.addSubview(knightView)
        currentKnight = knightView
        kRow = Int(row)
        kCol = Int(col)
    }
    
    func drawGunman(row: CGFloat, col: CGFloat)
    {
        currentGunman.removeFromSuperview()
        let gunmanView = UIImageView(image: #imageLiteral(resourceName: "gunman"))
        gunmanView.frame = CGRect(x: col * colSpacing + 10, y: row * rowSpacing + 10, width: rowSpacing - 20, height: colSpacing - 20)
        self.addSubview(gunmanView)
        currentGunman = gunmanView
        gRow = Int(row)
        gCol = Int(col)
    }
    
    func teleportKnight(row: Int, col: Int)
    {
        drawKnight(row: CGFloat(row), col: CGFloat(col))
        
        if doesKnightCheckmateGunman()
        {
            let alertView = UIAlertController(title: "Game Over!", message: "The Knight Wins!", preferredStyle: .alert)
            
            alertView.addAction(UIAlertAction(title: "Main Menu", style: .default, handler: { (action : UIAlertAction) in
                
                _ = self.GVC.navigationController?.popToRootViewController(animated: false)
                
            }))
            
            GVC.present(alertView, animated: true, completion: nil)
            
            GVC.moveLabel.text = "Knight Wins!"
        }
    }
    
    func teleportGunman(row: Int, col: Int)
    {
        drawGunman(row: CGFloat(row), col: CGFloat(col))
    }
    
    func autoTeleportKnight()
    {
        var randIndex = arc4random_uniform(UInt32(numRows * numCols))
        let gunmanIndex = 5 * gCol + gRow
        let knightIndex = 5 * kCol + kRow
        
        kCol = Int(randIndex) / numCols
        kCol = Int(randIndex) % numRows
        
        var failed = false
        var i = 0
        
        while Int(randIndex) == gunmanIndex || eliminated.contains(Int(randIndex)) || Int(randIndex) == knightIndex || doesKnightCheckmateGunman() || doesGunmanCheckmateKnight()
        {
            randIndex = arc4random_uniform(UInt32(numRows * numCols))
            kCol = Int(randIndex) / numCols
            kRow = Int(randIndex) % numRows
            
            if i == numRows * numCols * 4
            {
                failed = true
                break
            }
            
            i += 1
        }
        
        if failed == true
        {
            for index in 0...numCols * numRows - 1
            {
                kCol = index / numCols
                kRow = index % numRows
                
                if !(Int(randIndex) == gunmanIndex || eliminated.contains(Int(randIndex)) || Int(randIndex) == knightIndex || doesKnightCheckmateGunman() || doesGunmanCheckmateKnight())
                {
                    randIndex = UInt32(index)
                    failed = false
                    break
                }
            }
            
            if failed == true
            {
                let alertView = UIAlertController(title: "Game Over!", message: "The Spearman Wins!", preferredStyle: .alert)
                
                alertView.addAction(UIAlertAction(title: "Main Menu", style: .default, handler: { (action : UIAlertAction) in
                    
                    _ = self.GVC.navigationController?.popToRootViewController(animated: false)
                    
                }))
                
                GVC.present(alertView, animated: true, completion: nil)
                
                GVC.moveLabel.text = "Spearman Wins!"
                
            }
            
        }
        
        let kAlertView = UIAlertController(title: "Trapped!", message: "The Knight is trapped and must teleport.", preferredStyle: .alert)
        
        kAlertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action : UIAlertAction) in
            
            self.teleportKnight(row: self.kRow, col: self.kCol)
            
        }))
        
        GVC.present(kAlertView, animated: true, completion: nil)
    }
    
    func autoTeleportGunman()
    {
        var randIndex = arc4random_uniform(UInt32(numRows * numCols))
        let knightIndex = 5 * kCol + kRow
        let gunmanIndex = 5 * gCol + gRow
        
        gCol = Int(randIndex) / numCols
        gRow = Int(randIndex) % numRows
        
        var failed = false
        var i = 0
        
        while Int(randIndex) == knightIndex || eliminated.contains(Int(randIndex)) || doesKnightCheckmateGunman() || Int(randIndex) == gunmanIndex || doesGunmanCheckmateKnight()
        {
            randIndex = arc4random_uniform(UInt32(numRows * numCols))
            gCol = Int(randIndex) / numCols
            gRow = Int(randIndex) % numRows
            
            if i == numRows * numCols * 4
            {
                failed = true
                break
            }
            
            i += 1
        }
        
        if failed == true
        {
            for index in 0...numCols * numRows - 1
            {
                gCol = index / numCols
                gRow = index % numRows
                
                if !(Int(randIndex) == knightIndex || eliminated.contains(Int(randIndex)) || doesKnightCheckmateGunman() || Int(randIndex) == gunmanIndex || doesGunmanCheckmateKnight())
                {
                    randIndex = UInt32(index)
                    failed = false
                    break
                }
            }
            
            if failed == true
            {
                let alertView = UIAlertController(title: "Game Over!", message: "The Knight Wins!", preferredStyle: .alert)
                
                alertView.addAction(UIAlertAction(title: "Main Menu", style: .default, handler: { (action : UIAlertAction) in
                    
                    _ = self.GVC.navigationController?.popToRootViewController(animated: false)
                    
                }))
                
                GVC.present(alertView, animated: true, completion: nil)
                
                GVC.moveLabel.text = "Knight Wins!"

            }
        }
        
        let gAlertView = UIAlertController(title: "Trapped!", message: "The Spearman is trapped and must teleport.", preferredStyle: .alert)
        
        gAlertView.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action : UIAlertAction) in
            
            self.teleportGunman(row: self.gRow, col: self.gCol)
            
        }))
        
        GVC.present(gAlertView, animated: true, completion: nil)
    }
    
    func eliminateSpace()
    {
        var randIndex = arc4random_uniform(UInt32(numRows * numCols))
        let knightIndex = 5 * kCol + kRow
        let gunmanIndex = 5 * gCol + gRow
        
        while Int(randIndex) == knightIndex || Int(randIndex) == gunmanIndex || eliminated.contains(Int(randIndex))
        {
            randIndex = arc4random_uniform(UInt32(numRows * numCols))
        }
        
        let eliminateView = UIImageView(image: #imageLiteral(resourceName: "eliminate"))
        let randRow = Int(randIndex) % numRows
        let randCol = Int(randIndex) / numCols

        eliminateView.frame = CGRect(x: CGFloat(randCol) * colSpacing + 10, y: CGFloat(randRow) * rowSpacing + 10, width: rowSpacing - 20, height: colSpacing - 20)
        self.addSubview(eliminateView)
        
        eliminated.append(Int(randIndex))
        buttons[Int(randIndex)].isUserInteractionEnabled = false
        
        
        if (isGunmanTrapped())
        {
            autoTeleportGunman()
        }
        
        if(isKnightTrapped())
        {
            autoTeleportKnight()
        }
        
    }
    
    @IBAction func makeMove(sender: UIButton)
    {
        let selectedRow = sender.tag % numRows
        let selectedCol = sender.tag / numCols
        
        
        if (turn % 2 != 0)
        {
            if (abs(selectedRow - kRow) > 1 || abs(selectedCol - kCol) > 1 || (abs(selectedCol - kCol) == 0 && abs(selectedRow - kRow) == 0) || (selectedRow == gRow && selectedCol == gCol))
            {
                return
            }
            
            drawKnight(row: CGFloat(selectedRow), col: CGFloat(selectedCol))
            
            itIsGunmansMove = true
            itIsKnightsMove = false
            
            GVC.moveLabel.text = "Pass to Spearman."
            
            if (doesGunmanCheckmateKnight())
            {
                let alertView = UIAlertController(title: "Game Over!", message: "The Spearman Wins!", preferredStyle: .alert)
                
                alertView.addAction(UIAlertAction(title: "Main Menu", style: .default, handler: { (action : UIAlertAction) in
                    
                    _ = self.GVC.navigationController?.popToRootViewController(animated: false)
                    
                }))
                
                GVC.present(alertView, animated: true, completion: nil)
                
                GVC.moveLabel.text = "Spearman Wins!"
            }
        }
        else
        {
            if (abs(selectedRow - gRow) > 1 || abs(selectedCol - gCol) > 1 || (abs(selectedCol - gCol) == 0 && abs(selectedRow - gRow) == 0) || (selectedRow == kRow && selectedCol == kCol))
            {
                return
            }
            
            drawGunman(row: CGFloat(selectedRow), col: CGFloat(selectedCol))
            
            itIsGunmansMove = false
            itIsKnightsMove = true
            
            GVC.moveLabel.text = "Pass to Knight."
            
            eliminateSpace()
        }
        
        if (doesKnightCheckmateGunman())
        {
            let alertView = UIAlertController(title: "Game Over!", message: "The Knight Wins!", preferredStyle: .alert)
            
            alertView.addAction(UIAlertAction(title: "Main Menu", style: .default, handler: { (action : UIAlertAction) in
                
                _ = self.GVC.navigationController?.popToRootViewController(animated: false)
                
            }))
            
            GVC.present(alertView, animated: true, completion: nil)
            
            GVC.moveLabel.text = "Knight Wins!"
        }
        
        if (doesGunmanCheckmateKnight())
        {
            let alertView = UIAlertController(title: "Game Over!", message: "The Spearman Wins!", preferredStyle: .alert)
            
            alertView.addAction(UIAlertAction(title: "Main Menu", style: .default, handler: { (action : UIAlertAction) in
                
                _ = self.GVC.navigationController?.popToRootViewController(animated: false)
                
            }))
            
            GVC.present(alertView, animated: true, completion: nil)
            
            GVC.moveLabel.text = "Spearman Wins!"
        }
        
        turn += 1
    }
    
    func doesGunmanCheckKnight() -> Bool {
        
        if ((kCol == gCol) || (kRow == gRow))
        {
            knightIsInCheck = true
            return true
        }
        
        return false
    }
    
    func doesKnightCheckGunman(row: Int, col: Int) -> Bool {
        
        if (abs(row - kRow) <= 1 && abs(col - kCol) <= 1)
        {
            gunmanIsInCheck = true
            return true
        }
        
        return false
    }
    
    func knightCanMoveTo(square: Int) -> Bool {
        
        let col = square / 5
        let row = square % 5
        
        if (abs(col - kCol) <= 1 && abs(row - kRow) <= 1) {
            if (eliminated.contains(square) || getGunmanSquareNumber(row: gRow, col: gCol) == square) {
                return false
            }
            
            return true
        }
        return false
    }
    
    func gunmanCanMoveTo(square: Int) -> Bool {
        
        let col = square / 5
        let row = square % 5
        
        if (abs(col - gCol) <= 1 && abs(row - gRow) <= 1) {
            if (eliminated.contains(square) || getSquare(row: kRow, col: kCol) == square || doesKnightCheckGunman(row: row, col: col)) {
                gunmanCanMove = false
                return false
            }
            gunmanCanMove = true
            return true
        }
        gunmanCanMove = false
        return false
    }
    
    func doesKnightCheckmateGunman() -> Bool {
        
        let location = getGunmanLocation()
        
        
        if (location == "top-left-corner") {
            if (gunmanCanMoveTo(square: getSquare(row: gRow, col: gCol + 1)) || gunmanCanMoveTo(square: getSquare(row: gRow + 1, col: gCol + 1)) || gunmanCanMoveTo(square: getSquare(row: gRow + 1, col: gCol))) {
                return false
            }
        }
        else if (location == "top-right-corner") {
            if (gunmanCanMoveTo(square: getSquare(row: gRow + 1, col: gCol)) || gunmanCanMoveTo(square: getSquare(row: gRow + 1, col: gCol - 1)) || gunmanCanMoveTo(square: getSquare(row: gRow, col: gCol - 1))) {
                return false
            }
        }
        else if (location == "bottom-left-corner") {
            if (gunmanCanMoveTo(square: getSquare(row: gRow - 1, col: gCol)) || gunmanCanMoveTo(square: getSquare(row: gRow - 1, col: gCol + 1)) || gunmanCanMoveTo(square: getSquare(row: gRow, col: gCol + 1))) {
                return false
            }
        }
        else if (location == "bottom-right-corner") {
            if (gunmanCanMoveTo(square: getSquare(row: gRow - 1, col: gCol)) || gunmanCanMoveTo(square: getSquare(row: gRow - 1, col: gCol - 1)) || gunmanCanMoveTo(square: getSquare(row: gRow, col: gCol - 1))) {
                return false
            }
        }
        else if (location == "top-edge") {
            if (gunmanCanMoveTo(square: getSquare(row: gRow, col: gCol - 1)) || gunmanCanMoveTo(square: getSquare(row: gRow + 1, col: gCol - 1)) || gunmanCanMoveTo(square: getSquare(row: gRow + 1, col: gCol)) || gunmanCanMoveTo(square: getSquare(row: gRow + 1, col: gCol + 1)) || gunmanCanMoveTo(square: getSquare(row: gRow, col: gCol + 1))) {
                return false
            }
        }
        else if (location == "bottom-edge") {
            if (gunmanCanMoveTo(square: getSquare(row: gRow, col: gCol - 1)) || gunmanCanMoveTo(square: getSquare(row: gRow - 1, col: gCol - 1)) || gunmanCanMoveTo(square: getSquare(row: gRow - 1, col: gCol)) || gunmanCanMoveTo(square: getSquare(row: gRow - 1, col: gCol + 1)) || gunmanCanMoveTo(square: getSquare(row: gRow, col: gCol + 1))) {
                return false
            }
        }
        else if (location == "left-edge") {
            if (gunmanCanMoveTo(square: getSquare(row: gRow - 1, col: gCol)) || gunmanCanMoveTo(square: getSquare(row: gRow - 1, col: gCol + 1)) || gunmanCanMoveTo(square: getSquare(row: gRow, col: gCol + 1)) || gunmanCanMoveTo(square: getSquare(row: gRow + 1, col: gCol + 1)) || gunmanCanMoveTo(square: getSquare(row: gRow + 1, col: gCol))) {
                return false
            }
        }
        else if (location == "right-edge") {
            if (gunmanCanMoveTo(square: getSquare(row: gRow - 1, col: gCol)) || gunmanCanMoveTo(square: getSquare(row: gRow - 1, col: gCol - 1)) || gunmanCanMoveTo(square: getSquare(row: gRow, col: gCol - 1)) || gunmanCanMoveTo(square: getSquare(row: gRow + 1, col: gCol - 1)) || gunmanCanMoveTo(square: getSquare(row: gRow + 1, col: gCol))) {
                return false
            }
        }
        else if (location == "middle") {
            if (gunmanCanMoveTo(square: getSquare(row: gRow - 1, col: gCol - 1)) || gunmanCanMoveTo(square: getSquare(row: gRow - 1, col: gCol)) || gunmanCanMoveTo(square: getSquare(row: gRow - 1, col: gCol + 1)) || gunmanCanMoveTo(square: getSquare(row: gRow, col: gCol + 1)) || gunmanCanMoveTo(square: getSquare(row: gRow + 1, col: gCol + 1)) || gunmanCanMoveTo(square: getSquare(row: gRow + 1, col: gCol)) || gunmanCanMoveTo(square: getSquare(row: gRow + 1, col: gCol - 1)) || gunmanCanMoveTo(square: getSquare(row: gRow, col: gCol - 1))) {
                return false
            }
        }
        if (itIsGunmansMove) {
            return true
        }
        
        return false
    }
    
    func knightIsAdjacentToGunman() -> Bool {
        
        if ((gCol - kCol == 1 && gRow - kRow == 0) || (kRow - gRow == 1 && kCol - gCol == 0) || (kCol - gCol == 1 && kRow - gRow == 0) || (gRow - kRow == 1 && gCol - kCol == 0)) {
            return true
        }
        
        return false
    }
    
    func doesGunmanCheckmateKnight() -> Bool {
        
        var k = 0
        
        if (kCol == gCol && isKnightOnSameRowOrColumnAsSpearAndTrapped() ) {
            if (kRow > gRow) {
                for i in gRow..<kRow {
                    if (eliminated.contains(i)) {
                        return false
                    }
                }
            }
                
            else if (gRow > kRow) {
                for i in kRow..<gRow {
                    if (eliminated.contains(i)) {
                        return false
                    }
                }
            }
        }
            
        else if (kRow == gRow && isKnightOnSameRowOrColumnAsSpearAndTrapped()) {
            if (kCol > gCol) {
                k = gCol
                while (k < kCol) {
                    if (eliminated.contains(k)) {
                        return false
                    }
                    k = k + 5
                }
            }
            
            if (gCol > kCol) {
                k = kCol
                while (k < gCol) {
                    if (eliminated.contains(k)) {
                        return false
                    }
                    k = k + 5
                }
            }
        }
            
        else if (isKnightOnSameRowOrColumnAsSpearAndTrapped() || knightIsAdjacentToGunman() && itIsGunmansMove) {
            return true
        }
        
        return false
    }
    
    func isKnightOnSameRowOrColumnAsSpearAndTrapped() -> Bool {
        
        if (doesGunmanCheckKnight()) {
            if (gCol == kCol) {
                if (getKnightLocation() == "top-left-corner") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol + 1))) {
                        return true
                    }
                }
                    
                else if (getKnightLocation() == "top-right-corner") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol - 1))) {
                        return true
                    }
                }
                    
                else if (getKnightLocation() == "bottom-left-corner") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol + 1))) {
                        return true
                    }
                }
                    
                else if (getKnightLocation() == "bottom-right-corner") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol - 1))) {
                        return true
                    }
                    
                }
                    
                else if (getKnightLocation() == "top-edge") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol + 1))) {
                        return true
                    }
                }
                    
                else if (getKnightLocation() == "bottom-edge") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol + 1))) {
                        return true
                    }
                }
                    
                else if (getKnightLocation() == "left-edge") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol + 1))) {
                        return true
                    }
                }
                    
                else if (getKnightLocation() == "right-edge") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol - 1))) {
                        return true
                    }
                }
                    
                else if (getKnightLocation() == "middle") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol + 1))) {
                        return true
                    }
                    
                }
                
                
            }
                
            else if (gRow == gRow) {
                if (getKnightLocation() == "top-left-corner") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol + 1))) {
                        return true
                    }
                }
                    
                else if (getKnightLocation() == "top-right-corner") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol))) {
                        return true
                    }
                }
                    
                else if (getKnightLocation() == "bottom-left-corner") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol))) {
                        return true
                    }
                }
                    
                else if (getKnightLocation() == "bottom-right-corner") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol))) {
                        return true
                    }
                    
                }
                    
                else if (getKnightLocation() == "top-edge") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol + 1))) {
                        return true
                    }
                }
                    
                else if (getKnightLocation() == "bottom-edge") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol + 1))) {
                        return true
                    }
                }
                    
                else if (getKnightLocation() == "left-edge") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol))) {
                        return true
                    }
                }
                    
                else if (getKnightLocation() == "right-edge") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol))) {
                        return true
                    }
                }
                    
                else if (getKnightLocation() == "middle") {
                    if (eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol + 1))) {
                        return true
                    }
                    
                }
                
            }
        }
        return false
    }
    
    func getGunmanLocation() -> String {
        
        if (gRow == 0 && gCol == 0) {
            return "top-left-corner"
        }
            
        else if (gRow == 0 && gCol == 4) {
            return "top-right-corner"
        }
            
        else if (gRow == 4 && gCol == 0) {
            return "bottom-left-corner"
        }
            
        else if (gRow == 4 && gCol == 4) {
            return "bottom-right-corner"
        }
            
        else if ((gRow == 0 && gCol != 0) && (gRow == 0 && gCol != 4)) {
            return "top-edge"
        }
            
        else if ((gRow == 4 && gCol != 0) && (gRow == 4 && gCol != 4)) {
            return "bottom-edge"
        }
            
        else if ((gRow != 0 && gCol == 1) && (gRow != 4 && gCol != 1)) {
            return "left-edge"
        }
            
        else if ((gRow != 0 && gCol == 4) && (gRow != 4 && gCol == 4)) {
            return "right-edge"
        }
        
        return "middle"
    }
    
    func getKnightLocation() -> String {
        
        if (kRow == 0 && kCol == 0) {
            return "top-left-corner"
        }
            
        else if (kRow == 0 && kCol == 4) {
            return "top-right-corner"
        }
            
        else if (kRow == 4 && kCol == 0) {
            return "bottom-left-corner"
        }
            
        else if (kRow == 4 && kCol == 4) {
            return "bottom-right-corner"
        }
            
        else if ((kRow == 0 && kCol != 0) && (kRow == 0 && kCol != 4)) {
            return "top-edge"
        }
            
        else if ((kRow == 4 && kCol != 0) && (kRow == 4 && kCol != 4)) {
            return "bottom-edge"
        }
            
        else if ((kRow != 0 && kCol == 1) && (kRow != 4 && kCol != 1)) {
            return "left-edge"
        }
            
        else if ((kRow != 0 && kCol == 4) && (kRow != 4 && kCol == 4)) {
            return "right-edge"
        }
        
        return "middle"
    }
    
    func getKnightSquareNumber(row: Int, col: Int) -> Int {
        return (5 * col) + row
    }
    
    func getGunmanSquareNumber(row: Int, col: Int) -> Int {
        return (5 * col) + row
    }
    
    func getSquare(row: Int, col: Int) -> Int {
        return (5 * col) + row
    }
    
    func isGunmanTrapped() -> Bool {
        
        let location = getGunmanLocation()
        
        if (location == "top-left-corner") {
            if (eliminated.contains(getGunmanSquareNumber(row: gRow + 1, col: gCol)) && eliminated.contains(getGunmanSquareNumber(row: gRow, col: gCol + 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow + 1, col: gCol + 1))) {
                return true
            }
        }
        else if (location == "top-right-corner") {
            if (eliminated.contains(getGunmanSquareNumber(row: gRow + 1, col: gCol)) && eliminated.contains(getGunmanSquareNumber(row: gRow + 1, col: gCol - 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow, col: gCol - 1))) {
                return true
            }
        }
        else if (location == "bottom-left-corner") {
            if (eliminated.contains(getGunmanSquareNumber(row: gRow - 1, col: gCol)) && eliminated.contains(getGunmanSquareNumber(row: gRow - 1, col: gCol + 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow, col: gCol + 1))) {
                return true
            }
        }
        else if (location == "bottom-right-corner") {
            if (eliminated.contains(getGunmanSquareNumber(row: gRow, col: gCol - 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow - 1, col: gCol - 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow - 1, col: gCol))) {
                return true
            }
        }
        else if (location == "top-edge") {
            if (eliminated.contains(getGunmanSquareNumber(row: gRow, col: gCol - 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow + 1, col: gCol)) && eliminated.contains(getGunmanSquareNumber(row: gRow, col: gCol + 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow + 1, col: gCol - 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow + 1, col: gCol + 1))) {
                return true
            }
        }
        else if (location == "bottom-edge") {
            if (eliminated.contains(getGunmanSquareNumber(row: gRow, col: gCol - 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow - 1, col: gCol)) && eliminated.contains(getGunmanSquareNumber(row: gRow, col: gCol + 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow - 1, col: gCol - 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow - 1, col: gCol + 1))) {
                return true
            }
        }
        else if (location == "left-edge") {
            if (eliminated.contains(getGunmanSquareNumber(row: gRow - 1, col: gCol)) && eliminated.contains(getGunmanSquareNumber(row: gRow, col: gCol + 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow + 1, col: gCol)) && eliminated.contains(getGunmanSquareNumber(row: gRow - 1, col: gCol + 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow + 1, col: gCol + 1))) {
                return true
            }
        }
        else if (location == "right-edge") {
            if (eliminated.contains(getGunmanSquareNumber(row: gRow - 1, col: gCol)) && eliminated.contains(getGunmanSquareNumber(row: gRow, col: gCol - 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow + 1, col: gCol)) && eliminated.contains(getGunmanSquareNumber(row: gRow - 1, col: gCol - 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow + 1, col: gCol - 1))) {
                return true
            }
        }
        else if (location == "middle") {
            if (eliminated.contains(getGunmanSquareNumber(row: gRow - 1, col: gCol - 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow - 1, col: gCol)) && eliminated.contains(getGunmanSquareNumber(row: gRow - 1, col: gCol + 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow, col: gCol + 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow + 1, col: gCol + 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow + 1, col: gCol)) && eliminated.contains(getGunmanSquareNumber(row: gRow + 1, col: gCol - 1)) && eliminated.contains(getGunmanSquareNumber(row: gRow, col: gCol - 1))) {
                return true
            }
        }
        return false
    }
    
    func isKnightTrapped() -> Bool {
        
        let location2 = getKnightLocation()
        
        if (location2 == "top-left-corner") {
            if (eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol + 1))) {
                return true
            }
        }
            
        else if (location2 == "top-right-corner") {
            if (eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol - 1))) {
                return true
            }
        }
            
        else if (location2 == "bottom-left-corner") {
            if (eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol + 1))) {
                return true
            }
        }
            
        else if (location2 == "bottom-right-corner") {
            if (eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol))) {
                return true
            }
        }
            
        else if (location2 == "top-edge") {
            if (eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol + 1))) {
                return true
            }
            
        }
            
        else if (location2 == "bottom-edge") {
            if (eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol + 1))) {
                return true
            }
        }
            
        else if (location2 == "left-edge") {
            if (eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol + 1))) {
                return true
            }
        }
            
        else if (location2 == "right-edge") {
            if (eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol - 1))) {
                return true
            }
        }
            
        else if (location2 == "middle") {
            if (eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow - 1, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol + 1)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol)) && eliminated.contains(getKnightSquareNumber(row: kRow + 1, col: kCol - 1)) && eliminated.contains(getKnightSquareNumber(row: kRow, col: kCol - 1))) {
                return true
            }
        }
        return false
    }
}

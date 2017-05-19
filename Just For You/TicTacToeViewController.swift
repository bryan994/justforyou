
//
//  TicTacToeViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 06/04/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//

import UIKit

class TicTacToeViewController: UIViewController {
    
    enum Player: Int {
        
        case ComputerPlayer = 0, UserPlayer = 1
    }
    
    @IBOutlet var tic1: UIImageView!
    
    @IBOutlet var tic2: UIImageView!
    
    @IBOutlet var tic3: UIImageView!
    
    @IBOutlet var tic4: UIImageView!
    
    @IBOutlet var tic5: UIImageView!
    
    @IBOutlet var tic6: UIImageView!
    
    @IBOutlet var tic7: UIImageView!
    
    @IBOutlet var tic8: UIImageView!
    
    @IBOutlet var tic9: UIImageView!
    
    @IBOutlet var userMessage: UILabel!
    
    @IBOutlet var resetButton: UIButton!
    
    var plays = [Int:Int]()
    
    var done = false
    
    var aiDeciding = false
    
    var ticTacImages = [UIImageView]()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        ticTacImages = [tic1, tic2, tic3, tic4, tic5, tic6, tic7 ,tic8 ,tic9]
        
        for imageView in ticTacImages {
            
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageClicked(reco:))))
            
        }
        
        userMessage.isHidden = true
    }
    
    func imageClicked(reco: UITapGestureRecognizer) {
        
        let imageViewTapped = reco.view as! UIImageView
        
        if plays[imageViewTapped.tag] == nil && !aiDeciding && !done {
            
            setImageForSpot(spot: imageViewTapped.tag, player:.UserPlayer)
            
        }
        
        checkForWin()
        aiTurn()
        
    }
    
    func setImageForSpot(spot:Int,player:Player) {
        
        let playerMark = player == .UserPlayer ? "x" : "o"
        plays[spot] = player.rawValue
        
        switch spot {
            
        case 1:
            tic1.image = UIImage(named: playerMark)
        case 2:
            tic2.image = UIImage(named: playerMark)
        case 3:
            tic3.image = UIImage(named: playerMark)
        case 4:
            tic4.image = UIImage(named: playerMark)
        case 5:
            tic5.image = UIImage(named: playerMark)
        case 6:
            tic6.image = UIImage(named: playerMark)
        case 7:
            tic7.image = UIImage(named: playerMark)
        case 8:
            tic8.image = UIImage(named: playerMark)
        case 9:
            tic9.image = UIImage(named: playerMark)
        default:
            tic5.image = UIImage(named: playerMark)
            
        }
        
    }
    
    func checkForWin() {
        
        let whoWon = ["I":0,"you":1]
        for (key,value) in whoWon {
            
            if ((plays[7] == value && plays[8] == value && plays[9] == value) || //across the bottom
                (plays[4] == value && plays[5] == value && plays[6] == value) || //across the middle
                (plays[1] == value && plays[2] == value && plays[3] == value) || //across the top
                (plays[7] == value && plays[4] == value && plays[1] == value) || //down the left side
                (plays[8] == value && plays[5] == value && plays[2] == value) || //down the middle
                (plays[9] == value && plays[6] == value && plays[3] == value) || //down the right side
                (plays[7] == value && plays[5] == value && plays[3] == value) || //diagonal
                (plays[9] == value && plays[5] == value && plays[1] == value)){//diagonal
                
                userMessage.isHidden = false
                userMessage.text = "Looks like \(key) won!"
                resetButton.isHidden = false;
                done = true;
                
            }
        }
        
    }

    @IBAction func resetOnButtonPressed(_ sender: Any) {
        
        done = false
        resetButton.isHidden = true
        userMessage.isHidden = true
        reset()
        
    }
    
    func reset() {
        
        plays = [:]
        tic1.image = nil
        tic2.image = nil
        tic3.image = nil
        tic4.image = nil
        tic5.image = nil
        tic6.image = nil
        tic7.image = nil
        tic8.image = nil
        tic9.image = nil

    }
    
    func checkBottom(value:Int) -> (location:String, pattern:String) {
        
        return ("bottom",checkFor(value: value, inList: [7,8,9]))
        
    }
    func checkMiddleAcross(value:Int) -> (location:String, pattern:String) {
        
        return ("middleHorz",checkFor(value: value, inList: [4,5,6]))
        
    }
    func checkTop(value:Int) -> (location:String, pattern:String) {
        
        return ("top",checkFor(value: value, inList: [1,2,3]))
        
    }
    func checkLeft(value:Int) -> (location:String, pattern:String) {
        
        return ("left",checkFor(value: value, inList: [1,4,7]))
        
    }
    func checkMiddleDown(value:Int) -> (location:String, pattern:String) {
        
        return ("middleVert",checkFor(value: value, inList: [2,5,8]))
        
    }
    func checkRight(value:Int) ->  (location:String, pattern:String) {
        
        return ("right",checkFor(value: value, inList: [3,6,9]))
        
    }
    func checkDiagLeftRight(value:Int) ->  (location:String, pattern:String) {
        
        return ("diagLeftRight",checkFor(value: value, inList: [3,5,7]))
        
    }
    func checkDiagRightLeft(value:Int) ->  (location:String, pattern:String) {
        
        return ("diagRightLeft",checkFor(value: value, inList: [1,5,9]))
        
    }
    
    func checkFor(value:Int, inList:[Int]) -> String {
        
        var conclusion = ""
        for cell in inList {
            
            if plays[cell] == value {
                
                conclusion += "1"
                
            }else {
                
                conclusion += "0"
                
            }
        }
        
        return conclusion
    }
    
    func rowCheck(value:Int) -> (location:String, pattern:String)? {
        
        let acceptableFinds = ["011","110","101"]
        let findFuncs = [checkBottom, checkTop, checkRight, checkLeft, checkDiagLeftRight, checkDiagRightLeft, checkMiddleDown, checkMiddleAcross]
        for algorithm in findFuncs {
            
            let algorithmResults = algorithm(value)
            if acceptableFinds.index(of: algorithmResults.pattern) != nil {
                
                return algorithmResults
            }
        }
        
        return nil
    }
    
    func isOccupied(spot:Int) -> Bool {
        
        print("occupied \(spot)")
        if plays[spot] != nil {
            
            return true
            
        }
        
        return false
        
    }
    
    func whereToPlay(location:String,pattern:String) -> Int {
        
        let leftPattern = "011"
        let rightPattern = "110"
//        let middlePattern = "101"
        
        switch location {
            
        case "top":
            if pattern == leftPattern {
                
                return 1
                
            }else if pattern == rightPattern {
                
                return 3
                
            }else {
                
                return 2
                
            }
            
        case "bottom":
            if pattern == leftPattern {
                
                return 7
                
            }else if pattern == rightPattern {
                
                return 9
                
            }else {
                
                return 8
                
            }
            
        case "left":
            if pattern == leftPattern {
                
                return 1
                
            }else if pattern == rightPattern {
                
                return 7
                
            }else {
                
                return 4
                
            }
            
        case "right":
            if pattern == leftPattern {
                
                return 3
                
            }else if pattern == rightPattern {
                
                return 9
                
            }else {
                
                return 6
                
            }
            
        case "middleVert":
            if pattern == leftPattern {
                return 2
            }else if pattern == rightPattern {
                return 8
            }else {
                return 5
            }
        case "middleHorz":
            if pattern == leftPattern {
                
                return 4
                
            }else if pattern == rightPattern {
                
                return 6
                
            }else {
                
                return 5
                
            }
            
        case "diagLeftRight":
            if pattern == leftPattern {
                
                return 1
                
            }else if pattern == rightPattern {
                
                return 9
                
            }else {
                
                return 5
                
            }
            
        case "diagRightLeft":
            if pattern == leftPattern {
                
                return 3
                
            }else if pattern == rightPattern {
                
                return 7
                
            }else {
                
                return 5
                
            }
            
        default:
            return 4
        }
    }
    
    func aiTurn() {
        
        if done {
            
            return
            
        }
        
        aiDeciding = true
        //We (the computer) have two in a row
        if let result = rowCheck(value: 0) {
            
            print("comp has two in a row")
            let whereToPlayResult = whereToPlay(location: result.location, pattern: result.pattern)
            if !isOccupied(spot: whereToPlayResult) {
                
                setImageForSpot(spot: whereToPlayResult, player: .ComputerPlayer)
                aiDeciding = false
                checkForWin()
                return
                
            }
        }
        //They (the player) have two in a row
        if let result = rowCheck(value: 1) {
            
            let whereToPlayResult = whereToPlay(location: result.location, pattern: result.pattern)
            if !isOccupied(spot: whereToPlayResult) {
                
                setImageForSpot(spot: whereToPlayResult, player: .ComputerPlayer)
                aiDeciding = false
                checkForWin()
                return
                
            }
            
            //Is center available?
        }
        
        if !isOccupied(spot: 5) {
            
            setImageForSpot(spot: 5, player: .ComputerPlayer)
            aiDeciding = false
            checkForWin()
            return
            
        }
        
        func firstAvailable(isCorner: Bool)-> Int? {
            
            let spots = isCorner ? [1,3,7,9] : [2,4,6,8]
            
            for spot in spots {
                
                if !isOccupied(spot: spot) {
                    
                    return spot
                    
                }
            }
            
            return nil
            
        }
        
        if let cornerAvailable = firstAvailable(isCorner: true) {
            
            setImageForSpot(spot: cornerAvailable, player: .ComputerPlayer)
            aiDeciding = false
            checkForWin()
            return
            
        }
        
        if let sideAvailable = firstAvailable(isCorner: false) {
            
            setImageForSpot(spot: sideAvailable, player: .ComputerPlayer)
            aiDeciding = false
            checkForWin()
            return
            
        }
        
        userMessage.isHidden = false
        userMessage.text = "Looks like it was a tie!"
        
        reset()
        
        aiDeciding = false
    }


}

//
//  ViewController.swift
//  TypingBattleSwift
//
//  Created by Chase Gosingtian on 10/31/14.
//  Copyright (c) 2014 KLab Cyscorpions, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate {
    // IBOutlets
    @IBOutlet weak var wordToBeInputtedLabel: UILabel!
    @IBOutlet weak var submitWordButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var timerProgressView: UIProgressView!
    // Timer
    var timer: NSTimer = NSTimer()
    let timeInterval: NSTimeInterval = 1
    let timeMax: Float = 20
    var timeLeft: Float = 0
    // Game Setup
    var score: Int = 0
    var highestScore: Int = 0
    lazy var wordList: WordList = WordList()    // Word Index
    var lastIndexSelected: Int?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputTextField.delegate = self;
    }
    
    override func viewDidAppear(animated: Bool) {
        self.showInstructionsAlert()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Start and End Game
    func showInstructionsAlert() {
        updateProgressView()
        
        var alert = UIAlertController(
            title: "Welcome to Typing Battle",
            message: "Words will appear on screen - input them to earn 1 point per word. Earn the highest score before time runs out!",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        for alertAction:UIAlertAction in self.difficultyAlertActions() {
            alert.addAction(alertAction)
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func startGame(difficulty: Difficulties) {
        setDifficulty(difficulty)
        updateActiveWord()
        updateScore(0)
        self.inputTextField.becomeFirstResponder()
        startTimer()
    }
    
    func setDifficulty(difficulty: Difficulties) {
        switch (difficulty) {
            case .Easy:
                self.wordList.difficulty = .Easy
                break
            case .Medium:
                self.wordList.difficulty = .Medium
                break
            case .Hard:
                self.wordList.difficulty = .Hard
                break
            }
    }
    
    func endGame() {
        if (self.score > self.highestScore) {
            self.highestScore = self.score
        }
        
        var alert = UIAlertController(
            title: "Game Over!",
            message: "Your score was \(score).",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        for alertAction:UIAlertAction in self.difficultyAlertActions() {
            alert.addAction(alertAction)
        }
        
        let highScoreActionHandler = { (action:UIAlertAction!) -> Void in
            self.showHighestScore()
        }
        let highScoreAction = UIAlertAction(title: "Highest Score", style: .Default, handler: highScoreActionHandler)
        alert.addAction(highScoreAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showHighestScore() {
        var alert = UIAlertController(
            title: "Highest Score: \(highestScore)",
            message: "Play again?",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        for alertAction:UIAlertAction in self.difficultyAlertActions() {
            alert.addAction(alertAction)
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: Timer
    func startTimer() {
        timeLeft = timeMax
        updateProgressView()
        endTimer()
        timer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: "tickTimer", userInfo: nil, repeats: true)
    }
    
    func tickTimer() {
        timeLeft -= Float(timeInterval)
        updateProgressView()
        checkTimerDone()
    }
    
    func endTimer() {
        timer.invalidate()
    }
    
    func updateProgressView() {
        let percentageCompletion = timeLeft / timeMax
        timerProgressView.progress = percentageCompletion
    }
    
    func checkTimerDone() {
        if (timeLeft <= 0) {
            endTimer()
            endGame()
        }
    }
    
    // MARK: Word Matching Methods
    func checkWordsMatch(firstWord: String, secondWord: String) -> Bool {
        return (firstWord == secondWord)
    }
    
    func updateActiveWord() {
        var maxIndex = self.wordList.wordList().count
        var randomIndex = 0
        if self.lastIndexSelected != nil {
            do  {
                randomIndex = Int(arc4random_uniform(UInt32(maxIndex)))
                println("Randomizing... \(randomIndex) vs \(self.lastIndexSelected)")
            } while (randomIndex == self.lastIndexSelected!)
        } else {
            randomIndex = Int(arc4random_uniform(UInt32(maxIndex)))
        }
        self.lastIndexSelected = randomIndex
        
        var newWord = self.wordList.wordList()[randomIndex]
  
        dispatch_async(dispatch_get_main_queue()) {
            self.wordToBeInputtedLabel.text = newWord
            self.inputTextField.text = ""
        }
    }
    
    // MARK: Score Updating
    func updateScore(scoreValue: Int) {
        self.score = scoreValue
        dispatch_async(dispatch_get_main_queue()) {
            self.scoreLabel.text = "Score: \(self.score.description)"
        }
    }
    
    // MARK: UITextFieldDelegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        submitAnswer(textField)
        return true
    }
    
    // MARK: View Controller Settings
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    // MARK: IBActions
    @IBAction func submitAnswer(sender : AnyObject) {
        if (self.checkWordsMatch(self.inputTextField.text, secondWord: self.wordToBeInputtedLabel.text!)) {
            // Correct
            updateActiveWord()
            updateScore(self.score + self.wordToBeInputtedLabel.text!.utf16Count)
        } else {
            // Wrong
            self.inputTextField.selectAll(nil)
        }
    }
    
    // MARK: Alert Controller Helper Methods
    func difficultyAlertActions() -> [UIAlertAction] {
        let easyActionHandler = { (action:UIAlertAction!) -> Void in
            self.startGame(Difficulties.Easy)
        }
        let easyAction = UIAlertAction(title: "Play Easy", style: .Default, handler: easyActionHandler)
        
        let mediumActionHandler = { (action:UIAlertAction!) -> Void in
            self.startGame(Difficulties.Medium)
        }
        let mediumAction = UIAlertAction(title: "Play Medium", style: .Default, handler: mediumActionHandler)
        
        let hardActionHandler = { (action:UIAlertAction!) -> Void in
            self.startGame(Difficulties.Hard)
        }
        let hardAction = UIAlertAction(title: "Play Hard", style: .Default, handler: hardActionHandler)
        
        return [easyAction, mediumAction, hardAction]
    }
}


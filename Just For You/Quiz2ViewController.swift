//
//  Quiz2ViewController.swift
//  Just For You
//
//  Created by Bryan Lee on 29/03/2017.
//  Copyright © 2017 Bryan Lee. All rights reserved.
//


import UIKit
import SwiftyGif

class Quiz2ViewController: UIViewController {
    
    @IBOutlet var Buttons: [UIButton]!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var correctAnswerLabel: UILabel!
    
    @IBOutlet weak var nextQuestion: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    // To make sure the answer start from 0 because it will remove every answered question
    var questionNumber = Int()
    // To store answer from 0,1,2,3
    var answerNumber = Int()
    // An array to store the question, answers and which answers to choose from 0-3
    var questions = [Question]()
    // How many question answered correctly?
    var answerCorrectly = 0
    // To show the correct answer
    var correctAnswer = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.questions = [Question(Question: "How are you?", Answers: ["I'm Fine", "I'm okay", "I'm alright", "I'm good"], Number: 2),
      Question(Question: "Are you alright?", Answers: ["I'm Fine", "I'm okay", "I'm alright", "I'm good"], Number: 1),
      Question(Question: "Do you feel better?", Answers: ["I'm Fine", "I'm okay", "I'm alright", "I'm good"], Number: 2),
      Question(Question: "Do you feel better?", Answers: ["I'm Fine", "I'm okay", "I'm alright", "I'm good"], Number: 3),
      Question(Question: "Do you feel better?", Answers: ["I'm Fine", "I'm okay", "I'm alright", "I'm good"], Number: 2),
      Question(Question: "Do you feel better?", Answers: ["I'm Fine", "I'm okay", "I'm alright", "I'm good"], Number: 3),
      Question(Question: "Do you feel better?", Answers: ["I'm Fine", "I'm okay", "I'm alright", "I'm good"], Number: 2),
      Question(Question: "Do you feel better?", Answers: ["I'm Fine", "I'm okay", "I'm alright", "I'm good"], Number: 0),
      Question(Question: "Do you feel better?", Answers: ["I'm Fine", "I'm okay", "I'm alright", "I'm good"], Number: 1),
      Question(Question: "Do you feel better?", Answers: ["I'm Fine", "I'm okay", "I'm alright", "I'm good"], Number: 0)]
        
        hide()
        setQuestion()
        buttonDesign()
        
        self.navigationItem.hidesBackButton = true
        
    }
    
    func buttonDesign() {
        
        for button in Buttons{
            
            button.layer.cornerRadius = 5
            
        }
    }
    
    func showImageView() {
        
        let gifManager = SwiftyGifManager(memoryLimit:20)
        let gif = UIImage(gifName: "giphy.gif")
        self.imageView.setGifImage(gif, manager: gifManager)
        
    }
    
    func showImageView2() {
        
        let gifManager = SwiftyGifManager(memoryLimit:20)
        let gif = UIImage(gifName: "200w_d.gif")
        self.imageView.setGifImage(gif, manager: gifManager)
        
    }
    
    func setQuestion() {
        
        if questions.count > 0 {
            
            questionNumber = 0
            questionLabel.text = questions[questionNumber].Question
            answerNumber = questions[questionNumber].Number
            correctAnswer = questions[questionNumber].Answers
            
            print("\(correctAnswer)")
            
            for i in 0..<Buttons.count {
                
                Buttons[i].setTitle(questions[questionNumber].Answers[i], for: UIControlState.normal)
                
            }
            
            questions.remove(at: questionNumber)
            
        }else {
            
            let alertController = UIAlertController(title: "Congratulations!!!!", message: "Total correct: \(answerCorrectly)", preferredStyle: .alert)
            
            let dismissController = UIAlertAction(title: "OK", style: .cancel, handler: { action in self.navigationController?.popViewController(animated: true)})
            alertController.addAction(dismissController)
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func hide() {
        
        self.correctAnswerLabel.isHidden = true
        self.nextQuestion.isHidden = true
        self.imageView.isHidden = true

    }
    
    func unhide() {
        
        self.correctAnswerLabel.isHidden = false
        self.nextQuestion.isHidden = false
        self.imageView.isHidden = false

    }
    
    func disableAnswer() {
        
        for button in Buttons{
            
            button.isEnabled = false
            
        }
    }
    
    @IBAction func answer1(_ sender: Any) {
        
        unhide()
        fade()
        
        let isAnswer = correctAnswer[answerNumber]

        if (answerNumber == 0) {
            
            self.correctAnswerLabel.text = "You are definitely correct!!!"
            answerCorrectly = answerCorrectly + 1
            showImageView2()
            
            print("\(answerCorrectly)")
            
        }else {
            
            self.correctAnswerLabel.text = "ANSWER is \(isAnswer)"
            showImageView()
            
        }
        
        disableAnswer()
        
    }
    
    @IBAction func answer2(_ sender: Any) {
        
        unhide()
        fade()
        
        let isAnswer = correctAnswer[answerNumber]
        
        if (answerNumber == 1) {
            
            self.correctAnswerLabel.text = "You are definitely correct!!!"
            answerCorrectly = answerCorrectly + 1
            showImageView2()

            print("\(answerCorrectly)")
            
        }else {
            
            self.correctAnswerLabel.text = "ANSWER is \(isAnswer)"
            showImageView()
            
        }
        
        disableAnswer()
        
    }
    
    @IBAction func answer3(_ sender: Any) {
        
        unhide()
        fade()
        
        let isAnswer = correctAnswer[answerNumber]
        
        if (answerNumber == 2) {
            
            self.correctAnswerLabel.text = "You are definitely correct!!!"
            answerCorrectly = answerCorrectly + 1
            showImageView2()

            print("\(answerCorrectly)")
            
        }else {
            
            self.correctAnswerLabel.text = "ANSWER is \(isAnswer)"
            showImageView()
            
        }
        
        disableAnswer()
        
    }
    
    @IBAction func answer4(_ sender: Any) {
        
        unhide()
        fade()
        
        let isAnswer = correctAnswer[answerNumber]

        if (answerNumber == 3) {
            
            self.correctAnswerLabel.text = "You are definitely correct!!!"
            answerCorrectly = answerCorrectly + 1
            showImageView2()

            print("\(answerCorrectly)")
            
        }else {
            
            self.correctAnswerLabel.text = "ANSWER is \(isAnswer)"
            showImageView()
            
        }
        
        disableAnswer()
        
    }
    
    @IBAction func nextQuestion(_ sender: Any) {
        
        setQuestion()
        hide()
        
        for button in Buttons {
            
            button.isEnabled = true
            
        }
    }
    
    func fade() { 
        
        self.imageView.fadeIn(completion: {
            
            (finished: Bool) -> Void in
            self.imageView.fadeOut()
            
        })
    }
}

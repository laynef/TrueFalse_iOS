//
//  ViewController.swift
//  TrueFalseStarter
//
//  Created by Pasan Premaratne on 3/9/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import UIKit
import GameKit
import AudioToolbox

enum Constants: String {
    case Question
    case Answer
    case True
    case False
    case Maybe
    case IDontKnow
}

class ViewController: UIViewController {
    
    let questionsPerRound = 10
    var questionsAsked = 0
    var correctQuestions = 0
    var indexOfSelectedQuestion: Int = 0
    
    var correctAnswerSound: SystemSoundID = 0
    var introductionSound: SystemSoundID = 0
    var incorrectAnswerSound: SystemSoundID = 0
    
    let trivia: [[String : String]] = [
        [Constants.Question.rawValue: "Only female koalas can whistle", Constants.Answer.rawValue: Constants.False.rawValue],
        [Constants.Question.rawValue: "Blue whales are technically whales", Constants.Answer.rawValue: Constants.True.rawValue],
        [Constants.Question.rawValue: "Camels are cannibalistic", Constants.Answer.rawValue: Constants.Maybe.rawValue],
        [Constants.Question.rawValue: "Dr. Dre is a physician", Constants.Answer.rawValue: Constants.True.rawValue],
        [Constants.Question.rawValue: "We both have the same name", Constants.Answer.rawValue: Constants.IDontKnow.rawValue],
        [Constants.Question.rawValue: "Zombies are real", Constants.Answer.rawValue: Constants.Maybe.rawValue],
        [Constants.Question.rawValue: "Batman wears tights", Constants.Answer.rawValue: Constants.True.rawValue],
        [Constants.Question.rawValue: "Dogs are superior to cats", Constants.Answer.rawValue: Constants.True.rawValue],
        [Constants.Question.rawValue: "Horror movies aren't good the second time you see them", Constants.Answer.rawValue: Constants.Maybe.rawValue],
        [Constants.Question.rawValue: "All ducks are birds", Constants.Answer.rawValue: Constants.True.rawValue],
        [Constants.Question.rawValue: "Chinese food is delicious", Constants.Answer.rawValue: Constants.Maybe.rawValue],
        [Constants.Question.rawValue: "Pizza is not expectable at a wedding", Constants.Answer.rawValue: Constants.True.rawValue],
        [Constants.Question.rawValue: "Batman is the best superhero", Constants.Answer.rawValue: Constants.True.rawValue],
        [Constants.Question.rawValue: "Coffee is manditory", Constants.Answer.rawValue: Constants.True.rawValue],
        [Constants.Question.rawValue: "We both love basketball", Constants.Answer.rawValue: Constants.IDontKnow.rawValue],
        [Constants.Question.rawValue: "Superman is lame", Constants.Answer.rawValue: Constants.True.rawValue],
        [Constants.Question.rawValue: "As a developer will I work at a cubical", Constants.Answer.rawValue: Constants.Maybe.rawValue],
        [Constants.Question.rawValue: "Cats are great animals", Constants.Answer.rawValue: Constants.False.rawValue],
        [Constants.Question.rawValue: "Black coffee is superior to all other drinks", Constants.Answer.rawValue: Constants.True.rawValue],
        [Constants.Question.rawValue: "Football is the best sport in the world", Constants.Answer.rawValue: Constants.False.rawValue]
    ]
    
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var trueButton: UIButton!
    @IBOutlet weak var falseButton: UIButton!
    @IBOutlet weak var maybeButton: UIButton!
    @IBOutlet weak var iDontKnowButton: UIButton!
    @IBOutlet weak var playAgainButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameStartSound()
        loadCorrectAnswerSound()
        loadIncorrectAnswerSound()
        
        playGameStartSound()
        // Start game
        displayQuestion()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func randomNumber() -> Int {
        let randomNumber = Int(arc4random_uniform(UInt32(trivia.count)))
        return randomNumber
    }
    
    func displayQuestion() {
        indexOfSelectedQuestion = randomNumber()
        let questionDictionary = trivia[indexOfSelectedQuestion]
        questionField.text = questionDictionary[Constants.Question.rawValue]
        playAgainButton.hidden = true
    }
    
    func displayScore() {
        // Hide the answer buttons
        trueButton.hidden = true
        falseButton.hidden = true
        maybeButton.hidden = true
        iDontKnowButton.hidden = true
        
        // Display play again button
        playAgainButton.hidden = false
        
        questionField.text = "Way to go!\nYou got \(correctQuestions) out of \(questionsPerRound) correct!"
        
    }
    
    @IBAction func checkAnswer(sender: UIButton) {
        // Increment the questions asked counter
        questionsAsked += 1
        
        let selectedQuestionDict = trivia[indexOfSelectedQuestion]
        let correctAnswer = selectedQuestionDict[Constants.Answer.rawValue]
        
        
        
        if (sender === trueButton &&  correctAnswer == Constants.True.rawValue) || (sender === falseButton && correctAnswer == Constants.False.rawValue) || (sender === maybeButton && correctAnswer == Constants.Maybe.rawValue) || (sender === iDontKnowButton && correctAnswer == Constants.IDontKnow.rawValue) {
            correctQuestions += 1
            questionField.text = "Correct!"
            playCorrectAnswerSound()
        } else {
            questionField.text = "Sorry, wrong answer!"
            correctAlert()
            playIncorrectAnswerSound()
        }
        
        loadNextRoundWithDelay(seconds: 1)
    }
    
    func nextRound() {
        if questionsAsked == questionsPerRound {
            // Game is over
            displayScore()
            displayScoreAlert()
        } else {
            // Continue game
            displayQuestion()
        }
    }
    
    @IBAction func playAgain() {
        // Show the answer buttons
        trueButton.hidden = false
        falseButton.hidden = false
        maybeButton.hidden = false
        iDontKnowButton.hidden = false
        
        questionsAsked = 0
        correctQuestions = 0
        playGameStartSound()
        nextRound()
    }
    

    
    // MARK: Helper Methods
    
    func loadNextRoundWithDelay(seconds seconds: Int) {
        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, delay)
        
        // Executes the nextRound method at the dispatch time on the main queue
        dispatch_after(dispatchTime, dispatch_get_main_queue()) {
            self.nextRound()
        }
    }
    
    func correctAlert() {
        let selectedQuestionDict = trivia[indexOfSelectedQuestion]
        let correctAnswer = selectedQuestionDict[Constants.Answer.rawValue]
        
        let alertController = UIAlertController(title: "Correct Answer", message: "The correct is \(correctAnswer!)", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        alertController.addAction(action)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func displayScoreAlert() {
        let percentage = correctQuestions * 10
        
        let alertController = UIAlertController(title: "Final Score", message: "You got \(percentage)% of the questions right", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Okay", style: .Default, handler: nil)
        alertController.addAction(action)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func loadGameStartSound() {
        let pathToSoundFile = NSBundle.mainBundle().pathForResource("Introduction", ofType: "wav")
        let soundURL = NSURL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL, &introductionSound)
    }
    
    func loadCorrectAnswerSound() {
        let pathToSoundFile1 = NSBundle.mainBundle().pathForResource("GameSound", ofType: "wav")
        let soundURL1 = NSURL(fileURLWithPath: pathToSoundFile1!)
        AudioServicesCreateSystemSoundID(soundURL1, &correctAnswerSound)
    }
    
    func loadIncorrectAnswerSound() {
        let pathToSoundFile2 = NSBundle.mainBundle().pathForResource("Pain", ofType: "wav")
        let soundURL2 = NSURL(fileURLWithPath: pathToSoundFile2!)
        AudioServicesCreateSystemSoundID(soundURL2, &incorrectAnswerSound)
    }
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(introductionSound)
    }
    
    func playCorrectAnswerSound() {
        AudioServicesPlaySystemSound(correctAnswerSound)
    }
    
    func playIncorrectAnswerSound() {
        AudioServicesPlaySystemSound(incorrectAnswerSound)
    }
}


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
    case IDontKnow = "I Don't Know"
}

class ViewController: UIViewController {
    
    let questionsPerRound = 4
    var questionsAsked = 0
    var correctQuestions = 0
    var indexOfSelectedQuestion: Int = 0
    var phase: Int = 0
    var count = 15
    var timeSpeed = 1.0
    
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
    @IBOutlet weak var timerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameStartSound()
        loadCorrectAnswerSound()
        loadIncorrectAnswerSound()
        
        playGameStartSound()
        timerLabel.hidden = true
        // Start game
        displayQuestion()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var previousNumber: UInt32 = 0
    func randomNumber(maximum: Int) -> Int {
        var randomNumber = arc4random_uniform(UInt32(maximum))
        while (previousNumber == randomNumber) {
            randomNumber = arc4random_uniform(UInt32(maximum))
        }
        previousNumber = randomNumber
        
        return Int(randomNumber)
    }

    func displayQuestion() {
        phase = 1
        indexOfSelectedQuestion = randomNumber(trivia.count)
        let questionDictionary = trivia[indexOfSelectedQuestion]
        questionField.text = questionDictionary[Constants.Question.rawValue]
        playAgainButton.setTitle("Lightning Mode", forState: .Normal)
        count = 15
    }
    
    func displayScore() {
        // Hide the answer buttons
        trueButton.hidden = true
        falseButton.hidden = true
        maybeButton.hidden = true
        iDontKnowButton.hidden = true
        timerLabel.hidden = true
        playAgainButton.setTitle("Play Again", forState: .Normal)
        playAgainButton.hidden = false
        phase = 2
        
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
        count = 16
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
        if (phase == 1) {
            timerLabel.hidden = false
            displayTime(timeSpeed)
            playAgainButton.hidden = true
        } else {
            timerLabel.hidden = true
        }
        
        // Show the answer buttons
        if (phase == 2) {
            trueButton.hidden = false
            falseButton.hidden = false
            maybeButton.hidden = false
            iDontKnowButton.hidden = false
            
            count = 15
            questionsAsked = 0
            correctQuestions = 0
            timeSpeed = 1.0
            playGameStartSound()
            nextRound()
        }
    }
    
    // MARK: Helper Methods
    func countingTimer() {
        if (count > 0) {
            count -= 1
            if (count > 9) {
                timerLabel.text = "0:\(count)"
            } else {
                timerLabel.text = "0:0\(count)"
            }
        }
        if (count == 0) {
            displayScore()
            lightningFailDisplayScoreAlert()
            count = 15
        }
    }
    
    func displayTime(speed: Double) {
        NSTimer.scheduledTimerWithTimeInterval(speed, target: self, selector: #selector(self.countingTimer), userInfo: nil, repeats: true)
    }
    
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
        let percentage = (correctQuestions * 100) / questionsPerRound
        
        let alertController = UIAlertController(title: "Final Score", message: "You got \(percentage)% of the questions right", preferredStyle: .Alert)
        if (percentage == 100) {
            let action = UIAlertAction(title: "Good Job!", style: .Default, handler: nil)
            alertController.addAction(action)
        } else {
            let action = UIAlertAction(title: "Try Again", style: .Default, handler: nil)
            alertController.addAction(action)
        }
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func lightningFailDisplayScoreAlert() {
        let percentage = (correctQuestions * 100) / questionsPerRound
        
        let alertController = UIAlertController(title: "Failed Lightning Round", message: "You got \(percentage)% of the questions right", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Try Again", style: .Default, handler: nil)
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


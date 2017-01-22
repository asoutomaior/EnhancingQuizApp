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

class ViewController: UIViewController {
    
    let questionsPerRound = 10
    var questionsAsked = 0
    var correctQuestions = 0
    var indexOfSelectedQuestion: Int = 0
    
    var gameSound: SystemSoundID = 0
    var correctAnswerSound: SystemSoundID = 0
    var wrongAnswerSound: SystemSoundID = 0
    
    // Button colors
    let dimmedButtonBkgdColor = UIColor(red: 12/255, green: 121/255, blue: 150/255, alpha: 0.3)
    let dimmedButtonTitleColor = UIColor.init(white: 1.0, alpha: 0.2)
    let fullButtonBkgdColor = UIColor(red: 12/255, green: 121/255, blue: 150/255, alpha: 1.0)
    let fullButtonTitleColor = UIColor.init(white: 1.0, alpha: 1.0)
    
    // Answer text colors
    let wrongAnswerColor = UIColor(red: 255/255, green: 162/255, blue: 83/255, alpha: 1.0)
    let correctAnswerColor = UIColor(red: 0/255, green: 147/255, blue: 135/255, alpha: 1.0)
    
    // Instance of TriviaProvider struct, includes an array of trivia question/answer dictionaries
    let triviaProvider = TriviaProvider()
    
    // Empty array to hold non-repeating random numbers
    var nonRepeatingRandomNumbers: [Int] = []
    
    // Non-repeating random number indicator
    var numberIsRepeat = Bool()
    
    
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var answerField: UILabel!
    @IBOutlet weak var option1Button: UIButton!
    @IBOutlet weak var option2Button: UIButton!
    @IBOutlet weak var option3Button: UIButton!
    @IBOutlet weak var option4Button: UIButton!
    @IBOutlet weak var nextOrPlayAgainButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameStartSound()
        loadCorrectAnswerSound()
        loadWrongAnswerSound()
        
        // Start game
        playGameStartSound()
        displayQuestionAndOptions()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    
    
    func displayQuestionAndOptions() {
        
        print("button height is: \(option4Button.frame.size.height)")
        print("button width is: \(option4Button.frame.size.width)")
        print("button size is: \(option4Button.frame.size)")
        
        // Generate non-repeating random number
        generateAndCheckNonRepeatingNumber()
        
        // Set up answer options buttons
        let questionDictionary = triviaProvider.trivia[indexOfSelectedQuestion]
        questionField.text = questionDictionary["Question"]
        option1Button.setTitle(questionDictionary["Option 1"], for: .normal)
        option2Button.setTitle(questionDictionary["Option 2"], for: .normal)
        option3Button.setTitle(questionDictionary["Option 3"], for: .normal)
        
//        if questionDictionary["Option 4"] == nil {
//          option4Button.backgroundColor = dimmedBkgdColor
//          option4Button.frame.size = CGSize(width: 70, height: 60)
//            
//            print("button height2 is: \(option4Button?.frame.size.height)")
//            print("button width2 is: \(option4Button?.frame.size.width)")
//            print("button size2 is: \(option4Button?.frame.size)")
//            
//            print("There's nothin' here!!")
//        }
        
        option4Button.setTitle(questionDictionary["Option 4"], for: .normal)
        
        // Set up next question button
        nextOrPlayAgainButton.setTitle("Next Question", for: .normal)
        nextOrPlayAgainButton.isHidden = true
        answerField.isHidden = true
    }
    
    
    @IBAction func checkAnswer(_ sender: UIButton) {
        // Increment the questions asked counter
        questionsAsked += 1
        
        let selectedQuestionDict = triviaProvider.trivia[indexOfSelectedQuestion]
        let correctAnswer = selectedQuestionDict["Answer"]
        
        if (sender === option1Button &&  correctAnswer == "1") ||
            (sender === option2Button && correctAnswer == "2") ||
            (sender === option3Button && correctAnswer == "3") ||
            (sender === option4Button && correctAnswer == "4") {
            correctQuestions += 1
            answerField.textColor = correctAnswerColor
            answerField.text = "Yes! That's correct!! "
            answerField.isHidden = false
            playCorrectAnswerSound()
            
        } else {
            answerField.textColor = wrongAnswerColor
            answerField.text = "Nope! this is the answer..."
            answerField.isHidden = false
            playWrongAnswerSound()
        }
        
        // Dim the button colors
        buttonsDisplayDimmed()
        
        // Highlight button title text color on correct answers
        if correctAnswer == "1" {
            option1Button.setTitleColor(fullButtonTitleColor, for: .normal)
        } else if correctAnswer == "2" {
            option2Button.setTitleColor(fullButtonTitleColor, for: .normal)
        } else if correctAnswer == "3" {
            option3Button.setTitleColor(fullButtonTitleColor, for: .normal)
        } else if correctAnswer == "4" {
            option4Button.setTitleColor(fullButtonTitleColor, for: .normal)
        }

        // Display next question button
        nextOrPlayAgainButton.setTitle("Next Question", for: .normal)
        nextOrPlayAgainButton.isHidden = false
        
        // loadNextRoundWithDelay(seconds: 1)
    }
    
    
    @IBAction func nextOrPlayAgain() {
        // Show the answer buttons
        option1Button.isHidden = false
        option2Button.isHidden = false
        option3Button.isHidden = false
        option4Button.isHidden = false
        
        nextRound()
        buttonsDisplayFullColor()
    }
    
    
    func nextRound() {
        if questionsAsked == questionsPerRound {
            // Game is over
            answerField.isHidden = true
            displayScore()
        } else {
            // Continue game
            displayQuestionAndOptions()
        }
    }
    
    
    func displayScore() {
        // Hide the answer buttons
        option1Button.isHidden = true
        option2Button.isHidden = true
        option3Button.isHidden = true
        option4Button.isHidden = true
        
        // Display play again button
        nextOrPlayAgainButton.setTitle("Play Again", for: .normal)
        nextOrPlayAgainButton.isHidden = false
        
        questionField.text = "Way to go!\nYou got \(correctQuestions) out of \(questionsPerRound) correct!"
        
        questionsAsked = 0
        correctQuestions = 0
        
        // Reset random numbers collection
        nonRepeatingRandomNumbers = []
        
    }
    

    
    func buttonsDisplayDimmed() {
        option1Button.backgroundColor = dimmedButtonBkgdColor
        option1Button.setTitleColor(dimmedButtonTitleColor, for: .normal)
        option2Button.backgroundColor = dimmedButtonBkgdColor
        option2Button.setTitleColor(dimmedButtonTitleColor, for: .normal)
        option3Button.backgroundColor = dimmedButtonBkgdColor
        option3Button.setTitleColor(dimmedButtonTitleColor, for: .normal)
        option4Button.backgroundColor = dimmedButtonBkgdColor
        option4Button.setTitleColor(dimmedButtonTitleColor, for: .normal)
    }
    
    func buttonsDisplayFullColor() {
        option1Button.backgroundColor = fullButtonBkgdColor
        option1Button.setTitleColor(fullButtonTitleColor, for: .normal)
        option2Button.backgroundColor = fullButtonBkgdColor
        option2Button.setTitleColor(fullButtonTitleColor, for: .normal)
        option3Button.backgroundColor = fullButtonBkgdColor
        option3Button.setTitleColor(fullButtonTitleColor, for: .normal)
        option4Button.backgroundColor = fullButtonBkgdColor
        option4Button.setTitleColor(fullButtonTitleColor, for: .normal)
    }
    
    
    func generateAndCheckNonRepeatingNumber() {
        // Generate random number
        indexOfSelectedQuestion = GKRandomSource.sharedRandom().nextInt(upperBound: triviaProvider.trivia.count)
        print("new random number: \(indexOfSelectedQuestion)")
        
        // Check if it is a repeat number
        checkIfNumberIsRepeat()
        
        // If it is a repeat, generate new numbers until number is not a repeat
        while numberIsRepeat {
            print("generate one more number")
            indexOfSelectedQuestion = GKRandomSource.sharedRandom().nextInt(upperBound: triviaProvider.trivia.count)
            print("new number is: \(indexOfSelectedQuestion)")
            
            numberIsRepeat = false
            print("check new number")
            checkIfNumberIsRepeat()
        }
        
        // Add number to the collection of unique numbers
        nonRepeatingRandomNumbers.append(indexOfSelectedQuestion)
        print("new number appended to the array: \(indexOfSelectedQuestion)")
        print("updated array: \(nonRepeatingRandomNumbers)")
        
    }
    
    
    func checkIfNumberIsRepeat() {
        numberIsRepeat = false
        for randomNumber in nonRepeatingRandomNumbers {
            if randomNumber == indexOfSelectedQuestion {
                numberIsRepeat = true
                print("number is repeat")
            }
        }
    }
    
    
    
    
    
    // MARK: Helper Methods
    
    func loadNextRoundWithDelay(seconds: Int) {
        // Converts a delay in seconds to nanoseconds as signed 64 bit integer
        let delay = Int64(NSEC_PER_SEC * UInt64(seconds))
        
        // Calculates a time value to execute the method given current time and delay
        let dispatchTime = DispatchTime.now() + Double(delay) / Double(NSEC_PER_SEC)
        
        // Executes the nextRound method at the dispatch time on the main queue
        DispatchQueue.main.asyncAfter(deadline: dispatchTime) {
            self.nextRound()
        }
    }
    
    func loadGameStartSound() {
        let pathToSoundFile = Bundle.main.path(forResource: "GameSound", ofType: "mp3")
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameSound)
    }
    
    
    func loadCorrectAnswerSound() {
        let pathToSoundFile = Bundle.main.path(forResource: "CorrectAnswerSound", ofType: "mp3")
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &correctAnswerSound)
    }
    
    func loadWrongAnswerSound() {
        let pathToSoundFile = Bundle.main.path(forResource: "WrongAnswerSound", ofType: "mp3")
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &wrongAnswerSound)
    }
    
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
    
    func playCorrectAnswerSound() {
        AudioServicesPlaySystemSound(correctAnswerSound)
    }
    
    func playWrongAnswerSound() {
        AudioServicesPlaySystemSound(wrongAnswerSound)
    }
    
    
    
    
}


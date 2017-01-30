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
    // Game variables
    let questionsPerRound = 10
    var questionsAsked = 0
    var correctQuestions = 0
    var indexOfSelectedQuestion: Int = 0
    
    // Sounds
    var gameSound: SystemSoundID = 0
    var correctAnswerSound: SystemSoundID = 0
    var wrongAnswerSound: SystemSoundID = 0
    var nextAnswerSound: SystemSoundID = 0
    
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
    
    // Counter
    var timer = Timer()
    var counter: Int = Int()
    
    // Labels and buttons
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var answerField: UILabel!
    @IBOutlet weak var timerField: UILabel!
    @IBOutlet weak var option1Button: UIButton!
    @IBOutlet weak var option2Button: UIButton!
    @IBOutlet weak var option3Button: UIButton!
    @IBOutlet weak var option4Button: UIButton!
    @IBOutlet weak var nextOrPlayAgainButton: UIButton!

    // Height and space constraints
    @IBOutlet weak var button3HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var button3TopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var button4HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var button4TopSpaceConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load sounds
        loadGameStartSound()
        loadCorrectAnswerSound()
        loadWrongAnswerSound()
        loadNextAnswerSound()
        
        // Start game
        playGameStartSound()
        displayQuestionAndOptions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func displayQuestionAndOptions() {
        // Reset and start timer
        counter = 15
        updateTimer()
        
        // Generate non-repeating random number
        generateAndCheckNonRepeatingNumber()
        
        // Ensure question label is visble after DisplayScore view
        questionField.isHidden = false
        
        // Ensure timer label is visible
        timerField.isHidden = false

        // Ensure buttons are re-enabled after CheckAnswer view
        option1Button.isEnabled = true
        option2Button.isEnabled = true
        option3Button.isEnabled = true
        option4Button.isEnabled = true
        
        // Set up answer options buttons
        let questionDictionary = triviaProvider.trivia[indexOfSelectedQuestion]
        questionField.text = questionDictionary["Question"]
        option1Button.setTitle(questionDictionary["Option 1"], for: .normal)
        option2Button.setTitle(questionDictionary["Option 2"], for: .normal)
        option3Button.setTitle(questionDictionary["Option 3"], for: .normal)
        option4Button.setTitle(questionDictionary["Option 4"], for: .normal)
        
        // Enables mix of 3 and 4 choice questions, while re-spacing UI elements
        if questionDictionary["Option 3"] == nil {
            button3HeightConstraint.constant = 0
            button3TopSpaceConstraint.constant = 0
        } else {
            button3HeightConstraint.constant = 50
            button3TopSpaceConstraint.constant = 35
        }
        
        if questionDictionary["Option 4"] == nil {
            button4HeightConstraint.constant = 0
            button4TopSpaceConstraint.constant = 0
        } else {
            button4HeightConstraint.constant = 50
            button4TopSpaceConstraint.constant = 35
        }
        
        // Set up next question button
        nextOrPlayAgainButton.setTitle("Next Question", for: .normal)
        nextOrPlayAgainButton.isHidden = true
        answerField.isHidden = true
    }
    
    @IBAction func checkAnswer(_ sender: UIButton) {
        // Stop timer and hide timer field
        counter = -1
        timerField.isHidden = true
        
        // Show answer field
        answerField.isHidden = false
        
        // Increment the questions asked counter
        questionsAsked += 1
        
        // Extract the corret answer from TriviaProvider struct instance
        let selectedQuestionDict = triviaProvider.trivia[indexOfSelectedQuestion]
        let correctAnswer = selectedQuestionDict["Answer"]
        
        // Check if selected answer is the correct one and display the result
        if (sender === option1Button &&  correctAnswer == "1") ||
            (sender === option2Button && correctAnswer == "2") ||
            (sender === option3Button && correctAnswer == "3") ||
            (sender === option4Button && correctAnswer == "4") {
            correctQuestions += 1
            answerField.textColor = correctAnswerColor
            answerField.text = "Yes! That's correct!!"
            print("Yes! That's correct!!")
            playCorrectAnswerSound()
        } else {
            answerField.textColor = wrongAnswerColor
            answerField.text = "No! this is the answer..."
            print("Nope! this is the answer...")
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
        
        // Disable buttons so app won't crash if user presses buttons in this view
        option1Button.isEnabled = false
        option2Button.isEnabled = false
        option3Button.isEnabled = false
        option4Button.isEnabled = false

        // Display next question button
        nextOrPlayAgainButton.setTitle("Next Question", for: .normal)
        nextOrPlayAgainButton.isHidden = false
    }
    
    @IBAction func nextOrPlayAgain() {
        // Show the answer buttons
        option1Button.isHidden = false
        option2Button.isHidden = false
        option3Button.isHidden = false
        option4Button.isHidden = false
        // Go to next round, which may be either the score display or next round of questions
        nextRound()
        buttonsDisplayFullColor()
    }
    
    func nextRound() {
        if questionsAsked == questionsPerRound {
            // Game is over, display score
            timerField.isHidden = true
            displayScore()
        } else {
            // Continue game, display next round of questions
            displayQuestionAndOptions()
        }
    }
    
    func displayScore() {
        // Hide the answer buttons
        option1Button.isHidden = true
        option2Button.isHidden = true
        option3Button.isHidden = true
        option4Button.isHidden = true
        questionField.isHidden = true
        answerField.isHidden = false
        answerField.textColor = wrongAnswerColor
        
        
        // Display play again button
        nextOrPlayAgainButton.setTitle("Play Again", for: .normal)
        nextOrPlayAgainButton.isHidden = false
        
        // Display the score percentage with message
        let percentScore: Double = Double(correctQuestions) / Double(questionsPerRound) * 100.0
        
        switch (percentScore) {
        case 0..<40: answerField.text = "\(Int(percentScore))%...\nYou're a cat person aren't you?!"
        case 40..<80: answerField.text = "\(Int(percentScore))%...\nHmmm... You should try it again!!"
        case 80...100: answerField.text = "\(Int(percentScore))%...\nYo dawg, dat was da bomb!!"
        default: answerField.text = ""
        }
        
        // Reset question counts
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
    
    func updateTimer() {
        // Timer countdown with display text
        if counter > 1 {
            timerField.textColor = wrongAnswerColor
            timerField.text = "You have \(counter) seconds to answer"
            counter -= 1
            loadNextRoundWithDelay(seconds: 1)
        } else if counter == 1 {
            timerField.text = "Time is up!! Next question..."
            playNextAnswerSound()
            // Increment the questions asked counter
            counter -= 1
            loadNextRoundWithDelay(seconds: 1)
            print("time is up!")
        } else if counter == 0 {
            print("next round!")
            timer.invalidate()
            // Increment the questions asked counter
            questionsAsked += 1
            // Move to next round once timer reaches 0 min mark
            nextRound()
        } else {
            timer.invalidate()
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
            self.updateTimer()
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
    
    func loadNextAnswerSound() {
        let pathToSoundFile = Bundle.main.path(forResource: "NextAnswerSound", ofType: "mp3")
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &nextAnswerSound)
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
    
    func playNextAnswerSound() {
        AudioServicesPlaySystemSound(nextAnswerSound)
    }
}


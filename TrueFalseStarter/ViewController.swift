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
    
    let questionsPerRound = 4
    var questionsAsked = 0
    var correctQuestions = 0
    var indexOfSelectedQuestion: Int = 0
    
    var gameSound: SystemSoundID = 0
    
    let dimmedBkgdColor = UIColor(red: 12/255, green: 121/255, blue: 150/255, alpha: 0.3)
    let dimmedTitleColor = UIColor.init(white: 1.0, alpha: 0.2)
    let fullBkgdColor = UIColor(red: 12/255, green: 121/255, blue: 150/255, alpha: 1.0)
    let fullTitleColor = UIColor.init(white: 1.0, alpha: 1.0)
    
    
    // Create instance of TriviaProvider struct, which includes an array of trivia question/answer dictionaries
    let triviaProvider = TriviaProvider()
    
    
    @IBOutlet weak var questionField: UILabel!
    @IBOutlet weak var option1Button: UIButton!
    @IBOutlet weak var option2Button: UIButton!
    @IBOutlet weak var option3Button: UIButton!
    @IBOutlet weak var option4Button: UIButton!
    @IBOutlet weak var nextOrPlayAgainButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadGameStartSound()
        // Start game
        playGameStartSound()
        displayQuestionAndOptions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayQuestionAndOptions() {
        
        buttonsDisplayFullColor()
        
        indexOfSelectedQuestion = GKRandomSource.sharedRandom().nextInt(upperBound: triviaProvider.trivia.count)
        let questionDictionary = triviaProvider.trivia[indexOfSelectedQuestion]
        questionField.text = questionDictionary["Question"]
        option1Button.setTitle(questionDictionary["Option 1"], for: .normal)
        option2Button.setTitle(questionDictionary["Option 2"], for: .normal)
        option3Button.setTitle(questionDictionary["Option 3"], for: .normal)
        option4Button.setTitle(questionDictionary["Option 4"], for: .normal)
        
        // Set up next question button
        nextOrPlayAgainButton.setTitle("Next Question", for: .normal)
        nextOrPlayAgainButton.isHidden = true
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
            questionField.text = "Correct!"
        } else {
            questionField.text = "Sorry, wrong answer!"
        }
        
        buttonsDisplayDimmed()

        
        if correctAnswer == "1" {
            option1Button.setTitleColor(fullTitleColor, for: .normal)
        } else if correctAnswer == "2" {
            option2Button.setTitleColor(fullTitleColor, for: .normal)
        } else if correctAnswer == "3" {
            option3Button.setTitleColor(fullTitleColor, for: .normal)
        } else if correctAnswer == "4" {
            option4Button.setTitleColor(fullTitleColor, for: .normal)
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
    }
    
    func nextRound() {
        if questionsAsked == questionsPerRound {
            // Game is over
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
        let pathToSoundFile = Bundle.main.path(forResource: "GameSound", ofType: "wav")
        let soundURL = URL(fileURLWithPath: pathToSoundFile!)
        AudioServicesCreateSystemSoundID(soundURL as CFURL, &gameSound)
    }
    
    func playGameStartSound() {
        AudioServicesPlaySystemSound(gameSound)
    }
    
    func buttonsDisplayDimmed() {
        option1Button.backgroundColor = dimmedBkgdColor
        option1Button.setTitleColor(dimmedTitleColor, for: .normal)
        option2Button.backgroundColor = dimmedBkgdColor
        option2Button.setTitleColor(dimmedTitleColor, for: .normal)
        option3Button.backgroundColor = dimmedBkgdColor
        option3Button.setTitleColor(dimmedTitleColor, for: .normal)
        option4Button.backgroundColor = dimmedBkgdColor
        option4Button.setTitleColor(dimmedTitleColor, for: .normal)
    }
    
    func buttonsDisplayFullColor() {
        option1Button.backgroundColor = fullBkgdColor
        option1Button.setTitleColor(fullTitleColor, for: .normal)
        option2Button.backgroundColor = fullBkgdColor
        option2Button.setTitleColor(fullTitleColor, for: .normal)
        option3Button.backgroundColor = fullBkgdColor
        option3Button.setTitleColor(fullTitleColor, for: .normal)
        option4Button.backgroundColor = fullBkgdColor
        option4Button.setTitleColor(fullTitleColor, for: .normal)
    }
    
}


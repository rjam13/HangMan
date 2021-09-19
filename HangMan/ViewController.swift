//
//  ViewController.swift
//  HangMan
//
//  Created by Rey Jairus Marasigan on 8/29/21.
//

import UIKit

//UITextFieldDelegate for applying text length limit
class ViewController: UIViewController, UITextFieldDelegate {
    //UI labels
    var word: UILabel!
    var userAnswer: UITextField!
    var submit: UIButton!
    var scoreLabel: UILabel!
    var score = 0 {
        didSet {
        scoreLabel.text = "Score: \(score)"
        }
    }
    var mistakeLabel: UILabel!
    var mistakes = 0 {
        didSet {
        mistakeLabel.text = "Mistakes: \(mistakes) / 6"
        }
    }
    var letterView: UIView!
    var letterViewField: UILabel!
    
    //used for spliting the questionMarks into a characters array that can replace characters
    var partsOfquestionMarks = [Character]()
    //the solution split into characters array to check
    var partsOfsolution = [Character]()
    
    //stored words
    var potentialWords = [String]()
    //where words go after being played
    var usedWords = [String]()
    
    var width: Int = 50
    var height: Int = 50
    var lettersUsed = [UILabel]()
    var currentLetterUsed: Int = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadView()
        startGame()
    }
    
    func startGame() {
        mistakes = 0
        score = 0
        currentLetterUsed = 0
        usedWords = [""]
        loadWords()
        loadLevel()
    }
    
    func loadWords() {
        //makes txt file into a url type
        if let wordsFile = Bundle.main.url(forResource: "start", withExtension: "txt") {
            //the wordsFile url is turned into a single string
            if let wordsContent = try? String(contentsOf: wordsFile) {
                //the wordsContent, seperated by \n, is turned into an array of Strings
                potentialWords = wordsContent.components(separatedBy: "\n")
                }
        }
    }
    
    func loadLevel() {
        //the solution for the level
        var solution: String = ""
        
        //chooses random index of potentialWords
        let tmp = Int.random(in: 0...(potentialWords.count - 1))
        
        //removes the element of that index and inputs it into solution
        solution = potentialWords.remove(at: tmp)
        
        //test
        print(solution)
        
        //appends solution into usedWords
        usedWords.append(solution)
        
        //keeps track of all the places of each letter in solution
        partsOfsolution = Array(solution)
        partsOfquestionMarks.removeAll()
        
        //sets the word UILabel with question marks that is as long as solution.count
        for _ in 0...solution.count - 1 {
            partsOfquestionMarks.append("?")
        }

        word.text = String(partsOfquestionMarks)
    }
    
    override func loadView() {
        //used for making the background white
        view = UIView()
        view.backgroundColor = .white
        
        word = UILabel()
        word.translatesAutoresizingMaskIntoConstraints = false
        word.textAlignment = .center
        word.font = UIFont.systemFont(ofSize: 54)
        word.textColor = .black
        word.text = ""
        view.addSubview(word)
        
        userAnswer = UITextField()
        userAnswer.translatesAutoresizingMaskIntoConstraints = false
        userAnswer.textAlignment = .center
        userAnswer.font = UIFont.systemFont(ofSize: 44)
        userAnswer.backgroundColor = .lightGray
        userAnswer.textColor = .white
        //makes the keyboard appear
        userAnswer.isUserInteractionEnabled = true
        //for editing the maximum length acceptable for userAnswer
        userAnswer.delegate = self
        userAnswer.returnKeyType = .done
        view.addSubview(userAnswer)
        
        submit = UIButton(type: .system)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("SUBMIT", for: .normal)
        //touchUpInside is to tell UIKit that this button activates when the user press it and releases
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        view.addSubview(submit)
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont.systemFont(ofSize: 20)
        scoreLabel.textColor = .black
        scoreLabel.text = "Score: \(score)"
        view.addSubview(scoreLabel)
        
        mistakeLabel = UILabel()
        mistakeLabel.translatesAutoresizingMaskIntoConstraints = false
        mistakeLabel.textAlignment = .center
        mistakeLabel.font = UIFont.systemFont(ofSize: 20)
        mistakeLabel.textColor = .black
        mistakeLabel.text = "Mistakes: \(mistakes) / 6"
        view.addSubview(mistakeLabel)
        
        NSLayoutConstraint.activate([
            word.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            word.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -100),
            
            userAnswer.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            userAnswer.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 20),
            
            submit.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            submit.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -30),
            
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scoreLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10),
            
            mistakeLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            mistakeLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10),
        ])
        
        loadLetters()
    }
    
    func loadLetters() {
        letterView = UIView()
        letterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(letterView)
        letterView.layer.borderColor = UIColor.lightGray.cgColor
        letterView.layer.borderWidth = 2
        
        letterViewField = UILabel()
        letterViewField.translatesAutoresizingMaskIntoConstraints = false
        letterViewField.textColor = .black
        letterViewField.text = "Wrong Letters used:"
        letterViewField.font = UIFont.preferredFont(forTextStyle: .body)
        letterViewField.adjustsFontForContentSizeCategory = true

        letterView.addSubview(letterViewField)
        
        let row = 1
        for letterPos in 0..<6 {
            // create a placeholder for letter
            let letter = UILabel()
            letter.font = UIFont.preferredFont(forTextStyle: .body)
            letter.adjustsFontForContentSizeCategory = true

            // give the button some temporary text so we can see it on-screen
            letter.text = "_"
            letter.textColor = .black

            // calculate the frame of this button using its letterPos and row
            let frame = CGRect(x: (letterPos % 6 + 1) * width, y: row * height, width: width, height: height)
            letter.frame = frame
            
//            if letterPos == 6 {
//                row += 1
//            }

            // add letter to the letterView
            lettersUsed.append(letter)
            letterView.addSubview(letter)
        }
        
        NSLayoutConstraint.activate([
            letterView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -20),
            letterView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            letterView.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 80),
            letterView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            letterViewField.centerXAnchor.constraint(equalTo: letterView.centerXAnchor)
        ])
        
    }
    
    @objc func submitTapped() {
        //keeps the user input into answer
        guard let answer = userAnswer.text?.lowercased() else { return }
        //then into character
        let character = Character(answer)
        
        //if the solution contains character,
        if partsOfsolution.contains(character) {
            
            for (index, item) in partsOfsolution.enumerated() {
                //using the index where the character is in solution, replace the question mark of that same index in partsOfquestionMarks with character if character == item
                if character == item {
                    partsOfquestionMarks[index] = character
                }
            }
            
            word.text = String(partsOfquestionMarks)
            
        //increments mistakes if character does not exist within word
        } else {
            
            //once the mistakes reach 6, the game starts over
            if mistakes == 5 {
                let ac = UIAlertController(title: "RIP", message: "Game Over. Your final score is: \(score)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "start over", style: .default) {
                    [weak self] _ in
                    self?.letterView.removeFromSuperview()
                    self?.loadLetters()
                    self?.startGame()
                })
                present(ac, animated: true)
            }
            
            mistakes += 1
            let ac = UIAlertController(title: "nope", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
            present(ac, animated: true)
            
            lettersUsed[currentLetterUsed].text! = answer
            letterView.addSubview(lettersUsed[currentLetterUsed])
            currentLetterUsed += 1
            
        }
        
        //if the word is fully guessed
        if !partsOfquestionMarks.contains("?") {
            score += 1
            let ac = UIAlertController(title: "Nice!", message: "Good job! Ready for next level?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "yes", style: .default) {
                [weak self] _ in
                self?.loadLevel()
            })
            present(ac, animated: true)
            
            mistakes = 0
            letterView.removeFromSuperview()
            loadLetters()
            currentLetterUsed = 0
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //sets the max length of textfield
        let maxLength = 1
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}


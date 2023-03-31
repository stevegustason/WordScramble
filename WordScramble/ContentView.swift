//
//  ContentView.swift
//  WordScramble
//
//  Created by Steven Gustason on 3/29/23.
//

import SwiftUI

struct ContentView: View {
    // Array of strings to store words the user has entered previously
    @State private var usedWords = [String]()
    // Variable to hold the word from which the user is making new words
    @State private var rootWord = ""
    // Variable to bind to text field for user to enter new words
    @State private var newWord = ""
    // Variable to track the user's score
    @State private var score = 0
    
    // Function to have a user enter a word, format it, then add it to an array that will be displayed
    func addNewWord() {
        // Take our new word, make it all lower case, and trim any white spaces or new lines
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check to make sure our answer isn't blank - if it is, simply return
        guard answer.count > 0 else { return }
        
        // Check to make sure our answer is not a duplicate word using our isOriginal function - if it is a duplicate, use wordError to set our error alert
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        // Check to make sure our answer is a word that actually contains letters from the root word - if it isn't, use wordError to set our error alert
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        // Check to make sure our answer is a real word - - if it isn't, use wordError to set our error alert
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isLongEnough(word: answer) else {
            wordError(title: "Word not long enough", message: "3 letters barely counts!")
            return
        }
        
        guard isNew(word: answer) else {
            wordError(title: "Can't use root word", message: "At least try to think of something yourself!")
            return
        }
        
        // Insert our new word into our list of used words at the beginning of the array using an animation to make it look nice
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        // Reset newWord to be blank so a user can continue entering more words
        newWord = ""
        score += answer.count
    }
    
    // Function to start the game - load our start.txt file and pick a random word
    func startGame() {
        // Find the url for start.txt in our bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // Split the string into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                // Pick a random word, or use silkworm as the default
                rootWord = allWords.randomElement() ?? "silkworm"
                
                // Reset score at 0
                score = 0
                
                // Reset used words to an empty string
                usedWords = [String]()
                
                return
            }
        }
        // If we make it here, there was a problem, so we should trigger a crash and report the error
        fatalError("Could not load start.txt from bundle")
    }
    
    // Check to see if the word the user entered has already been used
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    // Check to see if the word the user entered only contains letter from the root word
    func isPossible(word: String) -> Bool {
        // Create a temporary variable holding our root word
        var tempWord = rootWord
        
        // For each letter in the user's entered word, check if it's in the root word - if it is remove it and continue on. If it isn't, return false because that's not a valid guess
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        // If we make it all the way to the end, return true
        return true
    }

    // Check to see if the user's entered word is actually a word
    func isReal(word: String) -> Bool {
        // Create an instance of SwiftUI's text checker
        let checker = UITextChecker()
        // Then we need to create a string range using all characters that Objective-C can use (Objective-C doesn't store emojis and other characters the same way as Swift)
        let range = NSRange(location: 0, length: word.utf16.count)
        // Then we can ask our text checker to report where it found any misspellings in our word, passing in the range to check, a position to start within the range (so we can do things like “Find Next”), whether it should wrap around once it reaches the end, and what language to use for the dictionary
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        // Now we can check for the special NSNotFound value which would indicate if the word was spelled correctly and return that boolean
        return misspelledRange.location == NSNotFound
    }
    
    // Check to see if the user's entered word is longer than 3 letters
    func isLongEnough(word: String) -> Bool {
        word.count > 3
    }
    
    // Check to make sure the user's entered word isn't just the original word
    func isNew(word: String) -> Bool {
        !(word == rootWord)
    }
    
    // Create properties to display any error alerts
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    // Create a function that receives parameters, then sets the error title and message and displays the alert
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Score: \(score)")
                    .font(.title3)
                List {
                    // Simple text field bound to our newWord variable for users to enter their words
                    TextField("Enter your word", text: $newWord)
                    // This modifier makes it so that the first letter of words is not capitalized by default so it doesn't look weird when a user enters a word and it gets automatically lowercased
                        .textInputAutocapitalization(.never)
            
                    // For each of our words in our usedWords array, add a row that contains an icon with the number of letters in the word the user entered alongside the word
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                // Add our random root word as the navigation title
                .navigationTitle(rootWord)
                // When a user hits enter, call the addNewWord function
                .onSubmit(addNewWord)
                // When the view is first shown, call the startGame function to kick things off
                .onAppear(perform: startGame)
                // Show our alert when showingError is True
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
                // Add a button so users can restart with a new word whenever they want to
                .toolbar {
                    Button("Restart", action: startGame)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  WordScramble
//
//  Created by Steven Gustason on 3/29/23.
//

import SwiftUI

// UIKit has a spell checker we can use. First, we make a word to check and an instance of UITextChecker
let word = "swift"
let checker = UITextChecker()

// Then we need to create a string range using all characters that Objective-C can use (Objective-C doesn't store emojis and other characters the same way as Swift)
let range = NSRange(location: 0, length: word.utf16.count)

// Then we can ask our text checker to report where it found any misspellings in our word, passing in the range to check, a position to start within the range (so we can do things like “Find Next”), whether it should wrap around once it reaches the end, and what language to use for the dictionary
let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

// Now we can check for the special NSNotFound value which would indicate if the word was spelled correctly
let allGood = misspelledRange.location == NSNotFound



struct ContentView: View {
    // Array of strings to store words the user has entered previously
    @State private var usedWords = [String]()
    // Variable to hold the word from which the user is making new words
    @State private var rootWord = ""
    // Variable to bind to text field for user to enter new words
    @State private var newWord = ""
    
    func addNewWord() {
        // Take our new word, make it all lower case, and trim any white spaces or new lines
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check to make sure our answer isn't blank - if it is, simply return
        guard answer.count > 0 else { return }
        
        // Insert our new word into our list of used words at the beginning of the array using an animation to make it look nice
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        // Reset newWord to be blank so a user can continue entering more words
        newWord = ""
    }
    
    func startGame() {
        // Find the url for start.txt in our bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // Split the string into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                // Pick a random word, or use silkworm as the default
                rootWord = allWords.randomElement() ?? "silkworm"
                
                return
            }
        }
        // If we make it here, there was a problem, so we should trigger a crash and report the error
        fatalError("Could not load start.txt from bundle")
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
        }
        // Add our random root word as the navigation title
        .navigationTitle(rootWord)
        // When a user hits enter, call the addNewWord function
        .onSubmit(addNewWord)
        // When the view is first shown, call the startGame function to kick things off
        .onAppear(perform: startGame)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

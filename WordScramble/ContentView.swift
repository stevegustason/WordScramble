//
//  ContentView.swift
//  WordScramble
//
//  Created by Steven Gustason on 3/29/23.
//

import SwiftUI


let input = """
            a
            b
            c
            """
// Separates out the components by each new line, so this would create an array ["a", "b", "c"]
let letters = input.components(separatedBy: "\n")

// You can use randomElement to pick a random element from an array
let letter = letters.randomElement()
// randomElement returns an optional string so you have to unwrap or nil coalesce it. You can also used trimmingCharacters to get rid of certain characters, in this case white space and new lines
let trimmed = letter?.trimmingCharacters(in: .whitespacesAndNewlines)

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
    let people = ["Finn", "Leia", "Luke", "Rey"]

    var body: some View {
        VStack {
            // Lists can combine static and dynamic content
            List {
                Text("Static Row")
                
                // When we need to identify each unique item in an array, we can pass the id \.self - this will make it so that if something is added or removed from the array it doesn't need to recalculate the whole thing
                ForEach(people, id: \.self) {
                    Text($0)
                }

                Text("Static Row")
            }
            .listStyle(.grouped)
            
            // If the list is made entirely of dynamic content, you can skip the ForEach entirely like so
            List(0..<5) {
                Text("Dynamic row \($0)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

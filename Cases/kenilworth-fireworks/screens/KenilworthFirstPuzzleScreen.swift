import SwiftUI

struct KenilworthFirstPuzzleScreen: View {
    @State private var showClue1 = false
    @State private var showClue2 = false
    @State private var showAnswerPrompt = false
    @State private var userAnswer = ""
    @State private var showWrongAnswer = false

    var onSolved: () -> Void

    var body: some View {
        ZStack {
            Image("Kenilworth_First_Puzzle")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                HStack(spacing: 20) {
                    Button("Need a clue") {
                        showClue1 = true
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)

                    Button("Solved it") {
                        showAnswerPrompt = true
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                }
                .padding()

                if showClue1 {
                    VStack(spacing: 10) {
                        Text("🧠 The location on the map is 11 – 3 = ...?")
                        if showClue2 {
                            Text("🐎 Where do animals that neigh live...?")
                        } else {
                            Button("Need another clue?") {
                                showClue2 = true
                            }
                        }

                        Button("Got it") {
                            showAnswerPrompt = true
                        }
                        .padding(.top, 5)
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .padding()
                }
            }

            if showAnswerPrompt {
                Color.black.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Text("Enter your answer:")
                        .font(.headline)
                        .foregroundColor(.white)

                    TextField("Your answer here", text: $userAnswer)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    Button("Submit") {
                        checkAnswer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)

                    if showWrongAnswer {
                        Text("Hmm, try again!")
                            .foregroundColor(.red)
                    }
                }
                .padding()
            }
        }
    }

    func checkAnswer() {
        let correctAnswers = ["stables", "the stables", "horse barn", "stable"]
        let trimmedAnswer = userAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if correctAnswers.contains(trimmedAnswer) {
            onSolved()
        } else {
            showWrongAnswer = true
        }
    }
}

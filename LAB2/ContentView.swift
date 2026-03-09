import SwiftUI

struct ContentView: View {
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var quizFinished = false

    let questions: [Question] = [
        Question(text: "What is the capital of Sweden?",
                 options: ["Gothenburg", "Stockholm", "Malmö", "Uppsala"],
                 correctAnswer: "Stockholm"),
        Question(text: "Which keyword declares a constant in Swift?",
                 options: ["var", "let", "const", "def"],
                 correctAnswer: "let"),
        Question(text: "What does iOS stand for?",
                 options: ["Internet Operating System", "iPhone OS", "Integrated OS", "Internal OS"],
                 correctAnswer: "iPhone OS"),
        Question(text: "Which company makes the iPhone?",
                 options: ["Google", "Samsung", "Apple", "Microsoft"],
                 correctAnswer: "Apple"),
        Question(text: "What layout container stacks views vertically in SwiftUI?",
                 options: ["HStack", "ZStack", "VStack", "List"],
                 correctAnswer: "VStack"),
    ]

    var body: some View {
        if quizFinished {
            ResultsView(score: score, total: questions.count, onRestart: {
                currentQuestionIndex = 0
                score = 0
                quizFinished = false
            })
        } else {
            QuestionView(
                question: questions[currentQuestionIndex],
                questionNumber: currentQuestionIndex + 1,
                total: questions.count,
                onAnswer: { isCorrect in
                    if isCorrect { score += 1 }
                    if currentQuestionIndex + 1 < questions.count {
                        currentQuestionIndex += 1
                    } else {
                        quizFinished = true
                    }
                }
            )
        }
    }
}

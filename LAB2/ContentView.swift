import SwiftUI

struct Question {
    let text: String
    let options: [String]
    let correctIndex: Int
}

class QuizViewModel: ObservableObject {
    let allQuestions: [Question] = [
        Question(text: "What does 'var' mean in Swift?",
                 options: ["A constant", "A variable", "A function", "A type"],
                 correctIndex: 1),
        Question(text: "Which keyword defines a constant in Swift?",
                 options: ["var", "val", "let", "const"],
                 correctIndex: 2),
        Question(text: "What is SwiftUI primarily used for?",
                 options: ["Server-side code", "Building user interfaces", "Database queries", "Networking"],
                 correctIndex: 1),
        Question(text: "What does @State do in SwiftUI?",
                 options: ["Fetches data from network", "Manages local view state", "Defines a constant", "Creates animations"],
                 correctIndex: 1),
        Question(text: "Which of these is a SwiftUI layout container?",
                 options: ["UIStackView", "VStack", "LinearLayout", "FrameLayout"],
                 correctIndex: 1),
        Question(text: "What symbol marks an optional in Swift?",
                 options: ["!", "*", "?", "&"],
                 correctIndex: 2),
        Question(text: "What does 'guard let' do?",
                 options: ["Loops through a list", "Safely unwraps an optional and exits if nil", "Declares a guard variable", "Creates a constant"],
                 correctIndex: 1),
        Question(text: "Which keyword is used for inheritance in Swift?",
                 options: ["extends", "implements", ":", "inherits"],
                 correctIndex: 2),
        Question(text: "What is a closure in Swift?",
                 options: ["A type of loop", "A self-contained block of functionality", "A SwiftUI view", "A database connection"],
                 correctIndex: 1),
        Question(text: "What does 'async/await' relate to?",
                 options: ["UI animations", "Asynchronous programming", "Array sorting", "Memory management"],
                 correctIndex: 1),
        Question(text: "Which property wrapper observes an ObservableObject?",
                 options: ["@State", "@Binding", "@ObservedObject", "@Published"],
                 correctIndex: 2),
        Question(text: "What is a struct in Swift?",
                 options: ["A reference type", "A value type", "A protocol", "A closure"],
                 correctIndex: 1),
    ]

    @Published var currentIndex = 0
    @Published var score = 0
    @Published var selectedAnswer: Int? = nil
    @Published var quizFinished = false
    @Published var difficulty: Difficulty = .medium

    enum Difficulty: String, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"

        var questionCount: Int {
            switch self {
            case .easy:   return 4
            case .medium: return 8
            case .hard:   return 12
            }
        }
    }

    var questions: [Question] {
        Array(allQuestions.prefix(difficulty.questionCount))
    }

    var currentQuestion: Question {
        questions[currentIndex]
    }

    var isAnswered: Bool {
        selectedAnswer != nil
    }

    var isCorrect: Bool {
        selectedAnswer == currentQuestion.correctIndex
    }

    func selectAnswer(_ index: Int) {
        guard selectedAnswer == nil else { return }
        selectedAnswer = index
        if index == currentQuestion.correctIndex {
            score += 1
        }
    }

    func nextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            selectedAnswer = nil
        } else {
            quizFinished = true
        }
    }

    func restart() {
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        quizFinished = false
    }
}

struct StartView: View {
    @ObservedObject var vm: QuizViewModel
    @Binding var started: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Text("🧠")
                    .font(.system(size: 80))
                Text("Pop Quiz")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Test your Swift knowledge!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 12) {
                Text("Select Difficulty")
                    .font(.headline)

                HStack(spacing: 12) {
                    ForEach(QuizViewModel.Difficulty.allCases, id: \.self) { level in
                        Button {
                            vm.difficulty = level
                        } label: {
                            VStack(spacing: 4) {
                                Text(level.rawValue)
                                    .fontWeight(.semibold)
                                Text("\(level.questionCount) questions")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(vm.difficulty == level ? Color.purple : Color(.systemGray5))
                            .foregroundColor(vm.difficulty == level ? .white : .primary)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(.horizontal)

            Button {
                started = true
            } label: {
                Text("Start Quiz")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal)

            Spacer()
        }
    }
}

struct AnswerButton: View {
    let label: String
    let index: Int
    let correctIndex: Int
    let selectedAnswer: Int?
    let action: () -> Void

    var isSelected: Bool { selectedAnswer == index }
    var isCorrect: Bool  { index == correctIndex }
    var isAnswered: Bool { selectedAnswer != nil }

    var bgColor: Color {
        guard isAnswered else { return Color(.systemGray6) }
        if isCorrect { return Color.green.opacity(0.25) }
        if isSelected { return Color.red.opacity(0.25) }
        return Color(.systemGray6)
    }

    var borderColor: Color {
        guard isAnswered else { return Color.clear }
        if isCorrect { return .green }
        if isSelected { return .red }
        return Color.clear
    }

    var icon: String? {
        guard isAnswered else { return nil }
        if isCorrect { return "checkmark.circle.fill" }
        if isSelected { return "xmark.circle.fill" }
        return nil
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .multilineTextAlignment(.leading)
                Spacer()
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(isCorrect ? .green : .red)
                }
            }
            .padding()
            .background(bgColor)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 2))
            .cornerRadius(12)
        }
        .foregroundColor(.primary)
        .disabled(isAnswered)
    }
}

struct QuestionView: View {
    @ObservedObject var vm: QuizViewModel

    var body: some View {
        VStack(spacing: 24) {

            VStack(spacing: 6) {
                HStack {
                    Text("Question \(vm.currentIndex + 1) of \(vm.questions.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Score: \(vm.score)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                }
                ProgressView(value: Double(vm.currentIndex + 1), total: Double(vm.questions.count))
                    .tint(.purple)
            }
            .padding(.horizontal)

            Text(vm.currentQuestion.text)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .frame(minHeight: 80)

            if vm.isAnswered {
                HStack(spacing: 8) {
                    Image(systemName: vm.isCorrect ? "checkmark.seal.fill" : "xmark.seal.fill")
                    Text(vm.isCorrect ? "Correct!" : "Wrong — the answer was \"\(vm.currentQuestion.options[vm.currentQuestion.correctIndex])\"")
                        .font(.subheadline)
                }
                .foregroundColor(vm.isCorrect ? .green : .red)
                .padding(.horizontal)
            }

            VStack(spacing: 12) {
                ForEach(Array(vm.currentQuestion.options.enumerated()), id: \.offset) { index, option in
                    AnswerButton(
                        label: option,
                        index: index,
                        correctIndex: vm.currentQuestion.correctIndex,
                        selectedAnswer: vm.selectedAnswer
                    ) {
                        vm.selectAnswer(index)
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            if vm.isAnswered {
                Button {
                    vm.nextQuestion()
                } label: {
                    Text(vm.currentIndex + 1 < vm.questions.count ? "Next Question →" : "See Results")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: vm.isAnswered)
        .padding(.top)
    }
}

struct ResultsView: View {
    @ObservedObject var vm: QuizViewModel
    @Binding var started: Bool

    var percentage: Double {
        Double(vm.score) / Double(vm.questions.count)
    }

    var emoji: String {
        switch percentage {
        case 0.9...: return "🏆"
        case 0.7...: return "🎉"
        case 0.5...: return "👍"
        default:     return "📚"
        }
    }

    var message: String {
        switch percentage {
        case 0.9...: return "Outstanding!"
        case 0.7...: return "Great job!"
        case 0.5...: return "Not bad!"
        default:     return "Keep studying!"
        }
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text(emoji)
                .font(.system(size: 80))

            VStack(spacing: 8) {
                Text(message)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("\(vm.score) out of \(vm.questions.count) correct")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("\(vm.score)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("Correct")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)

                    VStack(spacing: 4) {
                        Text("\(vm.questions.count - vm.score)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        Text("Incorrect")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                }

                Text("\(Int(percentage * 100))%")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.purple)
            }
            .padding(.horizontal)

            VStack(spacing: 12) {
                Button {
                    vm.restart()
                } label: {
                    Text("Try Again")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }

                Button {
                    vm.restart()
                    started = false
                } label: {
                    Text("Change Difficulty")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
    }
}


struct ContentView: View {
    @StateObject private var vm = QuizViewModel()
    @State private var started = false

    var body: some View {
        if !started {
            StartView(vm: vm, started: $started)
        } else if vm.quizFinished {
            ResultsView(vm: vm, started: $started)
        } else {
            QuestionView(vm: vm)
        }
    }
}

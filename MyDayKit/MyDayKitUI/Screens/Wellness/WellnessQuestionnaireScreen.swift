//
//  WellnessQuestionnaireScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 16/04/2026.
//

import SwiftUI

// MARK: - WellnessQuestionnaireScreen
public struct WellnessQuestionnaireScreen: View {
    @ObservedObject var viewModel: WellnessQuestionnaireViewModel

    public var body: some View {
        ZStack {
            if viewModel.isComplete {
                WellnessCompleteView(scores: viewModel.scores, questions: viewModel.questions)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .bottom)),
                        removal: .opacity
                    ))
            } else {
                questionListView
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: viewModel.isComplete)
    }

    // MARK: - Question List
    private var questionListView: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        // Header
                        VStack(spacing: 4) {
                            Text("Daily Check-in")
                                .font(.title2).fontWeight(.bold)
                            Text("How are you feeling today?")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 8)

                        ForEach(Array(viewModel.questions.prefix(viewModel.revealedCount).enumerated()), id: \.element.id) { index, question in
                            let isActive = viewModel.activeQuestionId == question.id
                            let isAnswered = viewModel.scores[question.id] != nil

                            InlineQuestionCard(
                                question: question,
                                selectedScore: viewModel.scores[question.id],
                                isActive: isActive,
                                isEditable: viewModel.allAnswered,
                                onSelect: { score in
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        viewModel.scores[question.id] = score
                                    }

                                    // If editing an already answered question, just update score
                                    guard !viewModel.allAnswered else { return }

                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                        viewModel.revealNext()
                                    }

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                        withAnimation(.easeInOut(duration: 0.4)) {
                                            let nextIndex = index + 1
                                            if nextIndex < viewModel.questions.count {
                                                proxy.scrollTo("question_\(nextIndex)", anchor: .center)
                                            } else {
                                                proxy.scrollTo("submit_button", anchor: .bottom)
                                            }
                                        }
                                    }
                                },
                                onEditTapped: {
                                    // Tap header to re-activate a question when all answered
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.activeQuestionId = question.id
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            proxy.scrollTo("question_\(index)", anchor: .center)
                                        }
                                    }
                                }
                            )
                            .opacity(isActive || viewModel.allAnswered ? 1.0 : (isAnswered ? 0.45 : 1.0))
                            .animation(.easeInOut(duration: 0.3), value: viewModel.allAnswered)
                            .animation(.easeInOut(duration: 0.2), value: viewModel.activeQuestionId)
                            .padding(.horizontal, 20)
                            .id("question_\(index)")
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity
                            ))
                        }

                        // Submit
                        if viewModel.allAnswered {
                            Button(action: viewModel.submit) {
                                Text("Submit")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.orange)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 32)
                            .id("submit_button")
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity
                            ))
                        } else {
                            Spacer(minLength: 120)
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("question_0", anchor: .center)
                        }
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - InlineQuestionCard
struct InlineQuestionCard: View {
    let question: WellnessQuestion
    let selectedScore: WellnessScore?
    let isActive: Bool
    let isEditable: Bool
    let onSelect: (WellnessScore) -> Void
    let onEditTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: isActive ? 14 : 0) {
            // Question header — always visible, tappable when editable
            Button(action: {
                guard isEditable && !isActive else { return }
                onEditTapped()
            }) {
                HStack(spacing: 10) {
                    Text(question.emoji)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(question.title)
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        if isActive {
                            Text(question.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        if let selected = selectedScore {
                            Text(question.labels[selected.rawValue - 1])
                                .font(.caption).fontWeight(.medium)
                                .foregroundStyle(.orange)
                                .transition(.opacity)
                        }
                        if isEditable && !isActive {
                            Image(systemName: "pencil")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, isActive ? 0 : 0)

            // Score buttons — only shown when active
            if isActive {
                HStack(spacing: 6) {
                    ForEach(WellnessScore.allCases, id: \.rawValue) { score in
                        Button(action: { onSelect(score) }) {
                            VStack(spacing: 4) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedScore == score
                                              ? Color.orange
                                              : Color(.secondarySystemFill))
                                        .frame(height: 40)
                                    Text("\(score.rawValue)")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(selectedScore == score ? .white : .primary)
                                }
                                Text(question.labels[score.rawValue - 1])
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundStyle(selectedScore == score ? .orange : .secondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                        .animation(.easeInOut(duration: 0.15), value: selectedScore)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isActive ? Color.orange.opacity(0.5) : Color(.separator).opacity(0.4),
                    lineWidth: isActive ? 1.5 : 0.5
                )
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isActive)
    }
}

// MARK: - WellnessCompleteView
struct WellnessCompleteView: View {
    let scores: [String: WellnessScore]
    let questions: [WellnessQuestion]

    @State private var appeared = false

    private var entry: WellnessEntry? {
        guard
            let sleep    = scores["sleep"],
            let physical = scores["physical"],
            let mental   = scores["mental"],
            let mood     = scores["mood"]
        else { return nil }
        return WellnessEntry(
            sleepQuality: sleep,
            physicalReadiness: physical,
            mentalEnergy: mental,
            overallMood: mood
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Readiness score hero
                if let entry {
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(readinessColor(entry).opacity(0.12))
                                .frame(width: 100, height: 100)
                            VStack(spacing: 2) {
                                Text("\(Int(entry.readinessScore * 100))")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundStyle(readinessColor(entry))
                                Text("/ 100")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .scaleEffect(appeared ? 1 : 0.6)
                        .opacity(appeared ? 1 : 0)

                        VStack(spacing: 6) {
                            Text(entry.readinessLevel.label)
                                .font(.title3).fontWeight(.bold)
                                .foregroundStyle(readinessColor(entry))
                            Text(entry.readinessLevel.suggestion)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 8)
                    }
                    .padding(.top, 40)
                }

                // Score breakdown
                VStack(spacing: 0) {
                    ForEach(Array(questions.enumerated()), id: \.offset) { index, question in
                        HStack(spacing: 12) {
                            Text(question.emoji)
                                .font(.title3)
                                .frame(width: 32)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(question.title)
                                    .font(.subheadline)
                                Text(question.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if let score = scores[question.id] {
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(question.labels[score.rawValue - 1])
                                        .font(.subheadline).fontWeight(.semibold)
                                        .foregroundStyle(.orange)
                                    HStack(spacing: 2) {
                                        ForEach(1...5, id: \.self) { dot in
                                            Circle()
                                                .fill(dot <= score.rawValue ? Color.orange : Color(.tertiarySystemFill))
                                                .frame(width: 5, height: 5)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.8)
                            .delay(0.1 + Double(index) * 0.08),
                            value: appeared
                        )

                        if index < questions.count - 1 {
                            Divider().padding(.horizontal, 16)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.separator).opacity(0.4), lineWidth: 0.5)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }

    private func readinessColor(_ entry: WellnessEntry) -> Color {
        switch entry.readinessLevel {
        case .low:       return .red
        case .moderate:  return .orange
        case .good:      return .blue
        case .excellent: return .green
        }
    }
}

#Preview {
    WellnessQuestionnaireScreen(viewModel: WellnessQuestionnaireViewModel())
}

// MARK: - WellnessQuestionnaireViewModel
final class WellnessQuestionnaireViewModel: ObservableObject {
    @Published var scores: [String: WellnessScore] = [:]
    @Published var currentIndex: Int = 0
    @Published var isComplete: Bool = false
    // Add to WellnessQuestionnaireViewModel:
    @Published var revealedCount: Int = 1
    // Add to WellnessQuestionnaireViewModel
    @Published var activeQuestionId: String? = WellnessQuestion.all.first?.id

    let questions = WellnessQuestion.all
    let onComplete: ((WellnessEntry) -> ())?

    init(onComplete: ((WellnessEntry) -> ())? = nil) {
        self.onComplete = onComplete
    }

    var currentQuestion: WellnessQuestion {
        questions[currentIndex]
    }

    var isLastQuestion: Bool {
        currentIndex == questions.count - 1
    }

    var progress: Double {
        Double(currentIndex) / Double(questions.count)
    }

    func select(score: WellnessScore) {
        scores[currentQuestion.id] = score

        if isLastQuestion {
            submit()
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex += 1
            }
        }
    }

    func goBack() {
        guard currentIndex > 0 else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentIndex -= 1
        }
    }

    // Add to WellnessQuestionnaireViewModel:

    var answeredCount: Int {
        scores.count
    }

    var allAnswered: Bool {
        WellnessQuestion.all.allSatisfy { scores[$0.id] != nil }
    }
    
    func revealNext() {
        guard revealedCount < questions.count else { return }
        revealedCount += 1
        activeQuestionId = questions[revealedCount - 1].id
    }

    func submit() {
        guard allAnswered else { return }
        // existing submit logic
        guard
            let sleep    = scores["sleep"],
            let physical = scores["physical"],
            let mental   = scores["mental"],
            let mood     = scores["mood"]
        else { return }

        let entry = WellnessEntry(
            sleepQuality: sleep,
            physicalReadiness: physical,
            mentalEnergy: mental,
            overallMood: mood
        )

        withAnimation {
            isComplete = true
        }

        onComplete?(entry)
    }
}

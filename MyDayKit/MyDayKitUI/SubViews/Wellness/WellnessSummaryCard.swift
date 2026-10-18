//
//  WellnessSummaryCard.swift
//  MyDayKit
//
//  Created by Findlay Wood on 16/04/2026.
//

import SwiftUI

// MARK: - WellnessSummaryCard
struct WellnessSummaryCard: View {
    @ObservedObject var viewModel: WellnessQuestionnaireViewModel
    let isCurrentDay: Bool

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            if let entry = viewModel.completedEntry {
                completedView(entry: entry)
            } else if isCurrentDay {
                if isExpanded {
                    expandedView
                } else {
                    promptView
                }
            } else {
                pastDayView
            }
        }
        .background(isPrompting ? Color.clear : Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isPrompting ? Color.clear : borderColor, lineWidth: borderWidth)
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isExpanded)
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: viewModel.isComplete)
        .animation(.easeInOut(duration: 0.3), value: viewModel.allAnswered)
    }

    // MARK: - Prompt
    /// Not started today: the timeline's dashed slot rather than a card, because nothing is on
    /// it yet. "Start" expands the card inline exactly as before.
    private var promptView: some View {
        MyDayTimelinePlaceholder(
            title: "Check in",
            subtitle: "Sleep, body, focus and mood",
            actionTitle: "Start",
            actionTint: .matteGreen,
            action: { withAnimation { isExpanded = true } }
        )
    }

    // MARK: - Expanded
    private var expandedView: some View {
        VStack(spacing: 12) {
            // Header
            HStack(spacing: 14) {
                cardIcon(systemName: "sun.max.fill", color: .matteGreen)

                VStack(alignment: .leading, spacing: 3) {
                    Text("Daily Check-in")
                        .font(.subheadline).fontWeight(.semibold)
                    Text("How are you feeling today?")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button(action: { withAnimation { isExpanded = false } }) {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .background(Color(.secondarySystemFill))
                        .clipShape(Circle())
                }
            }

            Divider()

            // Questions
            VStack(spacing: 8) {
                ForEach(
                    Array(viewModel.questions.prefix(viewModel.revealedCount).enumerated()),
                    id: \.element.id
                ) { index, question in
                    questionRow(question: question, at: index)
                }
            }

            // Submit
            if viewModel.allAnswered {
                Button(action: viewModel.submit) {
                    Text("Submit")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Color.matteGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                    removal: .opacity
                ))
            }
        }
        .padding(16)
    }

    // MARK: - Question Row
    @ViewBuilder
    private func questionRow(question: WellnessQuestion, at index: Int) -> some View {
        let isActive = viewModel.activeQuestionId == question.id
        let isAnswered = viewModel.scores[question.id] != nil

        VStack(alignment: .leading, spacing: isActive ? 10 : 0) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(question.title)
                        .font(.subheadline).fontWeight(.semibold)
                    if isActive {
                        Text(question.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }

                Spacer()

                if let selected = viewModel.scores[question.id] {
                    HStack(spacing: 4) {
                        Text(question.labels[selected.rawValue - 1])
                            .font(.caption).fontWeight(.medium)
                            .foregroundStyle(Color.matteGreen)
                        if viewModel.allAnswered && !isActive {
                            Image(systemName: "pencil")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .transition(.opacity)
                    .onTapGesture {
                        guard viewModel.allAnswered else { return }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.activeQuestionId = question.id
                        }
                    }
                }
            }

            if isActive {
                scoreButtons(for: question)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(12)
        .background(isActive ? Color.matteGreen.opacity(0.05) : Color(.secondarySystemFill).opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color.matteGreen.opacity(0.4) : Color.clear, lineWidth: 1)
        )
        .opacity(isActive || viewModel.allAnswered ? 1.0 : (isAnswered ? 0.5 : 1.0))
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isActive)
        .animation(.easeInOut(duration: 0.3), value: viewModel.allAnswered)
    }

    // MARK: - Score Buttons
    /// Five numbered buttons with the scale's two ends captioned beneath, as the RPE card labels
    /// its 1–10. Each button used to carry its own label at 7pt — shrunk further by
    /// `minimumScaleFactor` — which no one can read on a phone. The chosen score's label is still
    /// shown in full, beside the question title.
    private func scoreButtons(for question: WellnessQuestion) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 5) {
                ForEach(WellnessScore.allCases, id: \.rawValue) { score in
                    let isSelected = viewModel.scores[question.id] == score
                    Button(action: { handleScoreSelection(score: score, for: question) }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isSelected ? Color.matteGreen : Color(.secondarySystemFill))
                                .frame(height: 38)
                            Text("\(score.rawValue)")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(isSelected ? .white : .primary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }

            HStack {
                Text("1 · \(question.labels.first ?? "")")
                Spacer()
                Text("5 · \(question.labels.last ?? "")")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 2)
        }
    }

    // MARK: - Completed
    private func completedView(entry: WellnessEntry) -> some View {
        HStack(spacing: 14) {
            cardIcon(systemName: "checkmark.circle.fill", color: readinessColor(entry))

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.readinessLevel.label)
                    .font(.subheadline).fontWeight(.semibold)
                Text(entry.readinessLevel.suggestion)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            HStack(spacing: 4) {
                ForEach([
                    entry.sleepQuality,
                    entry.physicalReadiness,
                    entry.mentalEnergy,
                    entry.overallMood
                ], id: \.rawValue) { score in
                    Circle()
                        .fill(scoreColor(score))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(16)
    }

    // MARK: - Past Day
    private var pastDayView: some View {
        HStack(spacing: 14) {
            cardIcon(systemName: "moon.zzz.fill", color: .secondary)

            VStack(alignment: .leading, spacing: 3) {
                Text("No Check-in")
                    .font(.subheadline).fontWeight(.semibold)
                Text("No wellness data was recorded for this day.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
    }

    // MARK: - Shared icon
    private func cardIcon(systemName: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.12))
                .frame(width: 50, height: 50)
            Image(systemName: systemName)
                .font(.system(size: 22))
                .foregroundStyle(color)
        }
    }

    // MARK: - Action
    private func handleScoreSelection(score: WellnessScore, for question: WellnessQuestion) {
        withAnimation(.easeInOut(duration: 0.15)) {
            viewModel.scores[question.id] = score
        }
        guard !viewModel.allAnswered else { return }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            viewModel.revealNext()
        }
    }

    // MARK: - Helpers
    /// The prompt draws its own dashed outline on the page, so the card's chrome steps aside.
    private var isPrompting: Bool {
        viewModel.completedEntry == nil && isCurrentDay && !isExpanded
    }

    private var borderColor: Color {
        if viewModel.isComplete  { return Color(.separator).opacity(0.4) }
        if isExpanded            { return Color.matteGreen.opacity(0.4) }
        return isCurrentDay ? Color.matteGreen.opacity(0.25) : Color(.separator).opacity(0.4)
    }

    private var borderWidth: CGFloat { isExpanded ? 1.5 : 0.5 }

    private func readinessColor(_ entry: WellnessEntry) -> Color {
        switch entry.readinessLevel {
        case .low:       return .matteRed
        case .moderate:  return .matteAmber
        case .good:      return .matteBlue
        case .excellent: return .matteGreen
        }
    }

    private func scoreColor(_ score: WellnessScore) -> Color {
        switch score {
        case .one:   return .matteRed
        case .two:   return .matteAmber
        case .three: return Color(.systemGray)
        case .four:  return .matteBlue
        case .five:  return .matteGreen
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 12) {
            WellnessSummaryCard(
                viewModel: WellnessQuestionnaireViewModel(),
                isCurrentDay: true
            )
            WellnessSummaryCard(
                viewModel: WellnessQuestionnaireViewModel(
                    existingEntry: WellnessEntry(
                        sleepQuality: .four,
                        physicalReadiness: .three,
                        mentalEnergy: .five,
                        overallMood: .four
                    )
                ),
                isCurrentDay: true
            )
            WellnessSummaryCard(
                viewModel: WellnessQuestionnaireViewModel(),
                isCurrentDay: false
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}

// MARK: - WellnessQuestionnaireViewModel
final class WellnessQuestionnaireViewModel: ObservableObject {

    // MARK: - Published
    @Published var scores: [String: WellnessScore] = [:]
    @Published var revealedCount: Int = 1
    @Published var activeQuestionId: String?
    @Published var isComplete: Bool = false
    @Published var completedEntry: WellnessEntry?

    // MARK: - Properties
    let questions = WellnessQuestion.all
    let onComplete: ((WellnessEntry) -> Void)?

    // MARK: - Init
    init(existingEntry: WellnessEntry? = nil, onComplete: ((WellnessEntry) -> Void)? = nil) {
        self.onComplete = onComplete

        if let entry = existingEntry {
            // Pre-populate from an already completed entry
            self.completedEntry = entry
            self.isComplete = true
            self.scores = [
                "sleep":    entry.sleepQuality,
                "physical": entry.physicalReadiness,
                "mental":   entry.mentalEnergy,
                "mood":     entry.overallMood
            ]
            self.revealedCount = questions.count
            self.activeQuestionId = nil
        } else {
            self.activeQuestionId = questions.first?.id
        }
    }

    // MARK: - Computed
    var allAnswered: Bool {
        questions.allSatisfy { scores[$0.id] != nil }
    }

    var answeredCount: Int {
        scores.count
    }

    // MARK: - Functions
    func revealNext() {
        guard revealedCount < questions.count else { return }
        revealedCount += 1
        activeQuestionId = questions[revealedCount - 1].id
    }

    func submit() {
        guard allAnswered,
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

        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            completedEntry = entry
            isComplete = true
        }

        onComplete?(entry)
    }
}

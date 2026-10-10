//
//  ReplayJumpMeasureView.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import UIKit

/// The tagging controls over the replay: close and undo top left, the done
/// arrow top right once every event is tagged, frame stepping and a scrubber,
/// a message line, and one full-width tag button that names the event it will
/// mark next.
///
/// It had a fixed take-off button and a fixed landing button, which cannot
/// describe a drop jump's three tags. One button stepping through the test's
/// tag plan can describe any test.
class ReplayJumpMeasureView: UIView {

    // MARK: - Subviews
    var backButton: UIButton = makeTopButton(systemName: "xmark")
    var undoButton: UIButton = {
        let button = makeTopButton(systemName: "arrow.uturn.backward")
        button.isHidden = true
        return button
    }()
    var doneButton: UIButton = {
        let button = makeTopButton(systemName: "checkmark")
        button.isHidden = true
        return button
    }()
    var slider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .white.withAlphaComponent(0.8)
        slider.maximumTrackTintColor = .white.withAlphaComponent(0.3)
        slider.thumbTintColor = .white
        slider.maximumValue = 1
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    var forwardFrameButton: UIButton = makeStepButton(systemName: "chevron.forward")
    var backwardFrameButton: UIButton = makeStepButton(systemName: "chevron.backward")
    var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var tagButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .darkColor
        button.layer.cornerRadius = 14
        button.layer.cornerCurve = .continuous
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Properties
    private var markers: [UIImageView] = []

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpView()
    }
}

// MARK: - Configure
private extension ReplayJumpMeasureView {
    func setUpView() {
        backgroundColor = .black
        [backButton, undoButton, doneButton, slider, forwardFrameButton, backwardFrameButton, messageLabel, tagButton]
            .forEach(addSubview)
        constrainView()
    }

    func constrainView() {
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            undoButton.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            undoButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            doneButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),

            tagButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            tagButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            tagButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12),
            tagButton.heightAnchor.constraint(equalToConstant: 52),

            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: tagButton.topAnchor, constant: -12),

            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            slider.bottomAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -16),

            backwardFrameButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            backwardFrameButton.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -16),
            forwardFrameButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            forwardFrameButton.bottomAnchor.constraint(equalTo: slider.topAnchor, constant: -16),
        ])
    }

    static func makeTopButton(systemName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black.withAlphaComponent(0.45)
        button.layer.cornerRadius = 22
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }

    static func makeStepButton(systemName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black.withAlphaComponent(0.45)
        button.layer.cornerRadius = 14
        button.layer.cornerCurve = .continuous
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 72).isActive = true
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }
}

// MARK: - Display
extension ReplayJumpMeasureView {

    /// Shows the next tag to make, or that tagging is done.
    func show(prompt: String?, canUndo: Bool) {
        tagButton.setTitle(prompt ?? "All tagged", for: .normal)
        tagButton.isEnabled = prompt != nil
        tagButton.backgroundColor = prompt != nil ? .darkColor : .tertiarySystemFill
        undoButton.isHidden = !canUndo
        doneButton.isHidden = prompt != nil
    }

    func show(message: String?) {
        messageLabel.text = message
    }

    /// Drops a marker for `event` above the scrubber's thumb where it sits now.
    func addMarker(for event: JumpEvent) {
        let marker = UIImageView(image: UIImage(systemName: event.markerSymbol))
        marker.tintColor = .white
        marker.contentMode = .scaleAspectFit
        let thumbRect = slider.thumbRect(forBounds: slider.bounds, trackRect: slider.trackRect(forBounds: slider.bounds), value: slider.value)
        let thumbFrame = convert(thumbRect, from: slider)
        marker.frame = CGRect(x: thumbFrame.midX - 8, y: thumbFrame.minY - 20, width: 16, height: 16)
        addSubview(marker)
        markers.append(marker)
    }

    func removeLastMarker() {
        markers.popLast()?.removeFromSuperview()
    }
}

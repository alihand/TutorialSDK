//
//  TutorialView.swift
//  Beymen
//
//  Created by Ali Han DEMIR on 28.07.2025.
//  Copyright © 2025 Beymen. All rights reserved.
//

import UIKit

// MARK: - Models
public enum TutorialArrowPosition {
    case top
    case bottom
}

public struct TutorialStep {
    let anchorView: UIView
    let message: NSAttributedString
    var arrowPosition: TutorialArrowPosition? = nil
    var shouldContainerViewCornered: Bool = false
}
 
extension TutorialStep {
    public init(anchorView: UIView,
         attributedMessage message: NSAttributedString,
         arrowPosition: TutorialArrowPosition? = nil,
         shouldContainerBeCornered shouldContainerViewCornered: Bool = false) {
        self.anchorView = anchorView
        self.message = message
        self.arrowPosition = arrowPosition
        self.shouldContainerViewCornered = shouldContainerViewCornered
    }
}

// MARK: - Arrow View
final class ArrowPointerView: UIView {
    private let shapeLayer = CAShapeLayer()
    var isFlipped: Bool = false {
        didSet { setNeedsLayout() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        shapeLayer.fillColor = UIColor.white.cgColor
        layer.addSublayer(shapeLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawTriangle()
    }

    private func drawTriangle() {
        let path = UIBezierPath()
        if isFlipped {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height))
            path.addLine(to: CGPoint(x: bounds.width, y: 0))
        } else {
            path.move(to: CGPoint(x: 0, y: bounds.height))
            path.addLine(to: CGPoint(x: bounds.width / 2, y: 0))
            path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        }
        path.close()
        shapeLayer.path = path.cgPath
        shapeLayer.frame = bounds
    }
}

// MARK: - Tutorial View
public final class TutorialView: UIView {

    // MARK: - Properties
    private let arrowPosition: TutorialArrowPosition
    private var anchorMidX: CGFloat = 0

    // MARK: - UI Elements
    private lazy var arrowView: ArrowPointerView = {
        let view = ArrowPointerView()
        view.isFlipped = (arrowPosition == .bottom)
        return view
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)
        return view
    }()

    private lazy var newLabel: UILabel = {
        let label = UILabel()
        label.text = "Yeni"
        label.font = TutorialFonts.demiBold(10)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var newLabelContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(red: 11/255, green: 0/255, blue: 220/255, alpha: 1.0)
        container.layer.cornerRadius = 2
        container.addSubview(newLabel)
        NSLayoutConstraint.activate([
            newLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 5),
            newLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5),
            newLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            newLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
        ])
        return container
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var messageStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [newLabelContainer, messageLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var stepLabel: UILabel = {
        let label = UILabel()
        label.font = TutorialFonts.medium(9)
        label.isHidden = true
        label.textColor = .white
        label.backgroundColor = .black
        label.textAlignment = .center
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = TutorialFonts.medium(12)
        button.backgroundColor = .black
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 24, bottom: 6, right: 24)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var previousButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.setImage(UIImage(named: "reverseArrow"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var bottomStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [stepLabel, UIView(), previousButton, actionButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [messageStack, bottomStack])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init
    init(message: NSAttributedString,
         stepText: String? = nil,
         buttonTitle: String,
         shouldShowPreviousButton: Bool = false,
         arrowPosition: TutorialArrowPosition) {
        self.arrowPosition = arrowPosition
        super.init(frame: .zero)
        self.setupViews()
        self.configure(message: message,
                       stepText: stepText,
                       buttonTitle: buttonTitle,
                       shouldShowPreviousButton: shouldShowPreviousButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()

        let containerHeight = containerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        containerView.frame = CGRect(x: 0,
                                     y: arrowPosition == .top ? 10 : 0,
                                     width: bounds.width,
                                     height: containerHeight)

        arrowView.isFlipped = (arrowPosition == .bottom)

        let arrowWidth: CGFloat = 20
        let arrowHeight: CGFloat = 10
        let clampedMidX = max(10 + arrowWidth / 2, min(bounds.width - 10 - arrowWidth / 2, anchorMidX))
        let arrowX = clampedMidX - arrowWidth / 2

        arrowView.frame = CGRect(x: arrowX,
                                 y: arrowPosition == .top ? 0 : containerView.frame.maxY,
                                 width: arrowWidth,
                                 height: arrowHeight)
        
        stepLabel.layer.cornerRadius = stepLabel.bounds.height / 2
    }

    // MARK: - Setup
    private func configure(message: NSAttributedString,
                           stepText: String?,
                           buttonTitle: String,
                           shouldShowPreviousButton: Bool = false) {
        messageLabel.attributedText = message
        if let stepText = stepText {
            stepLabel.text = stepText
            stepLabel.isHidden = false
        }
        previousButton.isHidden = !shouldShowPreviousButton
        actionButton.setTitle(buttonTitle, for: .normal)
    }

    // MARK: - Helpers
    func setAnchorMidX(_ x: CGFloat) {
        self.anchorMidX = x
        setNeedsLayout()
    }

    @objc func dismissTooltip() {
        self.superview?.removeFromSuperview()
    }

    // MARK: - Presentation
    public static func show(from anchorView: UIView,
                     in containerView: UIView,
                     message: NSAttributedString,
                     stepText: String? = nil,
                     buttonTitle: String,
                     shouldShowPreviousButton: Bool = false,
                     shouldContainerViewCornered: Bool = false,
                     arrowPosition: TutorialArrowPosition? = nil,
                     onNextTappped: (() -> Void)? = nil,
                     onPreviousTapped: (() -> Void)? = nil) {

        guard let window = containerView.window ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }

        if let existingWrapper = window.subviews.first(where: { $0.accessibilityIdentifier == "TutorialWrapperView" }) {
            existingWrapper.removeFromSuperview()
        }

        let anchorFrame = anchorView.convert(anchorView.bounds, to: window)
        let maxTutorialWidth = UIScreen.main.bounds.width - 20
        let measuredHeight = self.measureHeight(
            message: message,
            stepText: stepText,
            buttonTitle: buttonTitle,
            shouldShowPreviousButton: shouldShowPreviousButton,
            maxWidth: maxTutorialWidth
        )
        let spaceAbove = anchorFrame.minY
        let spaceBelow = window.bounds.height - anchorFrame.maxY

        let resolvedArrowPosition: TutorialArrowPosition = arrowPosition ?? (spaceAbove > spaceBelow ? .bottom : .top)
        let tutorialY = resolvedArrowPosition == .bottom
            ? (anchorFrame.minY - measuredHeight - 16)
            : (anchorFrame.maxY + 16)

        let wrapperView = UIView()
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.accessibilityIdentifier = "TutorialWrapperView"
        window.addSubview(wrapperView)
        NSLayoutConstraint.activate([
            wrapperView.topAnchor.constraint(equalTo: window.topAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            wrapperView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: window.trailingAnchor)
        ])

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor)
        ])
        
        let anchorCloneContainer = UIView()
        anchorCloneContainer.translatesAutoresizingMaskIntoConstraints = false
        anchorCloneContainer.backgroundColor = .white
        if shouldContainerViewCornered {
            anchorCloneContainer.layer.cornerRadius = 7
        }
        anchorCloneContainer.layer.masksToBounds = true
        anchorCloneContainer.layer.borderColor = UIColor.clear.cgColor
        anchorCloneContainer.layer.borderWidth = 2.0
        anchorCloneContainer.layer.shadowColor = UIColor.black.cgColor
        anchorCloneContainer.layer.shadowOpacity = 0.1
        anchorCloneContainer.layer.shadowRadius = 6
        anchorCloneContainer.layer.shadowOffset = .zero

        let renderer = UIGraphicsImageRenderer(size: anchorView.bounds.size)
        let image = renderer.image { _ in
            anchorView.drawHierarchy(in: anchorView.bounds, afterScreenUpdates: true)
        }

        let anchorImageView = UIImageView(image: image)
        anchorImageView.translatesAutoresizingMaskIntoConstraints = false
        anchorImageView.contentMode = .scaleToFill
        anchorImageView.isUserInteractionEnabled = false
        anchorCloneContainer.addSubview(anchorImageView)

        NSLayoutConstraint.activate([
            anchorImageView.topAnchor.constraint(equalTo: anchorCloneContainer.topAnchor),
            anchorImageView.bottomAnchor.constraint(equalTo: anchorCloneContainer.bottomAnchor),
            anchorImageView.leadingAnchor.constraint(equalTo: anchorCloneContainer.leadingAnchor),
            anchorImageView.trailingAnchor.constraint(equalTo: anchorCloneContainer.trailingAnchor)
        ])

        wrapperView.addSubview(anchorCloneContainer)
        NSLayoutConstraint.activate([
            anchorCloneContainer.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: anchorFrame.origin.y),
            anchorCloneContainer.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: anchorFrame.origin.x),
            anchorCloneContainer.widthAnchor.constraint(equalToConstant: anchorFrame.width),
            anchorCloneContainer.heightAnchor.constraint(equalToConstant: anchorFrame.height)
        ])

        let tutorial = TutorialView(
            message: message,
            stepText: stepText,
            buttonTitle: buttonTitle,
            shouldShowPreviousButton: shouldShowPreviousButton,
            arrowPosition: resolvedArrowPosition
        )
        tutorial.translatesAutoresizingMaskIntoConstraints = false
        tutorial.setAnchorMidX(anchorFrame.midX - 10)
        wrapperView.addSubview(tutorial)

        NSLayoutConstraint.activate([
            tutorial.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: tutorialY),
            tutorial.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 10),
            tutorial.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -10),
            tutorial.widthAnchor.constraint(equalToConstant: maxTutorialWidth)
        ])

        let dismissTap = UITapGestureRecognizer(target: tutorial, action: #selector(tutorial.dismissTooltip))
        backgroundView.addGestureRecognizer(dismissTap)

        tutorial.actionButton.addAction(UIAction(handler: { _ in
            wrapperView.removeFromSuperview()
            onNextTappped?()
        }), for: .touchUpInside)
        
        tutorial.previousButton.addAction(UIAction(handler: { _ in
            wrapperView.removeFromSuperview()
            onPreviousTapped?()
        }), for: .touchUpInside)
    }
}

// MARK: - Multi-step
extension TutorialView {
    public static func show(steps: [TutorialStep],
                     in containerView: UIView,
                     startIndex: Int = 0) {
        guard !steps.isEmpty, startIndex >= 0, startIndex < steps.count else { return }

        func showStep(_ index: Int) {
            guard index >= 0, index < steps.count else { return }
            let step = steps[index]

            TutorialView.show(
                from: step.anchorView,
                in: containerView,
                message: step.message,
                stepText: steps.count > 1 ? "\(index + 1)/\(steps.count)" : nil,
                buttonTitle: index == steps.count - 1 ? "Bitir" : "Devam Et",
                shouldShowPreviousButton: index > 0,
                shouldContainerViewCornered: step.shouldContainerViewCornered,
                arrowPosition: step.arrowPosition,
                onNextTappped: {
                    showStep(index + 1)
                },
                onPreviousTapped: {
                    showStep(index - 1)
                }
            )
        }

        showStep(startIndex)
    }
}

// MARK: - Layout
extension TutorialView {
    func setupViews() {
        backgroundColor = .clear

        addSubview(containerView)
        addSubview(arrowView)

        NSLayoutConstraint.activate([
            stepLabel.heightAnchor.constraint(equalToConstant: 22),
            stepLabel.widthAnchor.constraint(equalToConstant: 22),

            previousButton.widthAnchor.constraint(equalToConstant: 32),
            previousButton.heightAnchor.constraint(equalToConstant: 32),

            actionButton.heightAnchor.constraint(equalToConstant: 32),

            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            newLabelContainer.widthAnchor.constraint(equalToConstant: 36),

            mainStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Measuring
    private static func measureHeight(message: NSAttributedString,
                                      stepText: String?,
                                      buttonTitle: String,
                                      shouldShowPreviousButton: Bool,
                                      maxWidth: CGFloat) -> CGFloat {
        let sizing = TutorialView(
            message: message,
            stepText: stepText,
            buttonTitle: buttonTitle,
            shouldShowPreviousButton: shouldShowPreviousButton,
            arrowPosition: .top
        )
        sizing.translatesAutoresizingMaskIntoConstraints = false

        let temp = UIView(frame: CGRect(x: 0, y: 0, width: maxWidth, height: 1))
        temp.addSubview(sizing)
        NSLayoutConstraint.activate([
            sizing.topAnchor.constraint(equalTo: temp.topAnchor),
            sizing.leadingAnchor.constraint(equalTo: temp.leadingAnchor),
            sizing.trailingAnchor.constraint(equalTo: temp.trailingAnchor),
            sizing.widthAnchor.constraint(equalToConstant: maxWidth)
        ])

        temp.setNeedsLayout()
        temp.layoutIfNeeded()

        let target = CGSize(width: maxWidth, height: UIView.layoutFittingCompressedSize.height)
        let containerHeight = sizing.containerView.systemLayoutSizeFitting(
            target,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        let arrowHeight: CGFloat = 10
        return containerHeight + arrowHeight
    }
}

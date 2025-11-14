//
//  FilterViewController.swift
//  CineMystApp
//
//  Programmatic filter UI: left tab list + right content area.
//  Returns chosen filters via completion closure.
//

import UIKit

/// Simple model representing chosen filters
struct MentorFilters {
    var skills: Set<String> = []
    var mentorRole: String? = nil
    var experience: String? = nil
    var priceMin: Int? = nil
    var priceMax: Int? = nil
}

final class FilterViewController: UIViewController {

    // MARK: Public
    /// called when "Show Results" tapped with current filters
    var onApplyFilters: ((MentorFilters) -> Void)?

    // MARK: UI components
    private let container = UIView()
    private let leftMenu = UIStackView()
    private let contentContainer = UIView()
    private let bottomBar = UIView()

    private let clearButton = UIButton(type: .system)
    private let showResultsButton = UIButton(type: .system)

    private var selectedTab: Tab = .skills {
        didSet { updateContentForSelectedTab() }
    }

    // filter state
    private var filters = MentorFilters()

    // static lists (you can replace with dynamic lists)
    private let skillsList = ["Acting", "Modeling", "Theatre", "Voice Over", "Anchoring"]
    private let mentorRoles = ["Senior Actor", "Director", "Freelancer", "Dubber"]
    private let experienceOptions = ["1 Year+", "2 Year+", "3 Year+"]

    // views for content (kept as properties to easily update)
    private let skillsStack = UIStackView()
    private let mentorRoleStack = UIStackView()
    private let experienceStack = UIStackView()
    private let priceStack = UIStackView()

    // price inputs
    private let priceMinField: UITextField = {
        let t = UITextField()
        t.placeholder = "Min"
        t.keyboardType = .numberPad
        t.borderStyle = .roundedRect
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()
    private let priceMaxField: UITextField = {
        let t = UITextField()
        t.placeholder = "Max"
        t.keyboardType = .numberPad
        t.borderStyle = .roundedRect
        t.translatesAutoresizingMaskIntoConstraints = false
        return t
    }()

    // MARK: Tabs
    private enum Tab: Int {
        case skills = 0, mentorRole, experience, price

        var title: String {
            switch self {
            case .skills: return "Skills"
            case .mentorRole: return "Mentor Role"
            case .experience: return "Experience"
            case .price: return "Price"
            }
        }
    }

    // MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupHierarchy()
        setupConstraints()
        buildLeftMenu()
        buildContentViews()
        updateContentForSelectedTab()
    }

    private func setupAppearance() {
        view.backgroundColor = UIColor(white: 0, alpha: 0.35) // dim behind
        modalPresentationStyle = .overFullScreen

        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false

        leftMenu.axis = .vertical
        leftMenu.alignment = .fill
        leftMenu.distribution = .fillEqually
        leftMenu.spacing = 0
        leftMenu.translatesAutoresizingMaskIntoConstraints = false

        contentContainer.translatesAutoresizingMaskIntoConstraints = false

        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = .clear

        clearButton.setTitle("Clear", for: .normal)
        clearButton.setTitleColor(.label, for: .normal)
        clearButton.layer.cornerRadius = 10
        clearButton.layer.borderWidth = 1
        clearButton.layer.borderColor = UIColor.systemGray4.cgColor
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)

        var cfg = UIButton.Configuration.filled()
        cfg.title = "Show Results"
        cfg.cornerStyle = .capsule
        cfg.baseBackgroundColor = UIColor(red: 0x43/255, green: 0x16/255, blue: 0x31/255, alpha: 1)
        cfg.baseForegroundColor = .white
        showResultsButton.configuration = cfg
        showResultsButton.translatesAutoresizingMaskIntoConstraints = false
        showResultsButton.addTarget(self, action: #selector(showResultsTapped), for: .touchUpInside)
    }

    private func setupHierarchy() {
        view.addSubview(container)
        container.addSubview(leftMenu)
        container.addSubview(contentContainer)
        container.addSubview(bottomBar)

        bottomBar.addSubview(clearButton)
        bottomBar.addSubview(showResultsButton)
    }

    private func setupConstraints() {
        // center container, but keep it narrow like a right panel
        NSLayoutConstraint.activate([
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.88),
            container.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.78),

            leftMenu.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            leftMenu.topAnchor.constraint(equalTo: container.topAnchor),
            leftMenu.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
            leftMenu.widthAnchor.constraint(equalToConstant: 120),

            contentContainer.leadingAnchor.constraint(equalTo: leftMenu.trailingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            contentContainer.topAnchor.constraint(equalTo: container.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            bottomBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 76),

            clearButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),
            clearButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 110),
            clearButton.heightAnchor.constraint(equalToConstant: 40),

            showResultsButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            showResultsButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            showResultsButton.widthAnchor.constraint(equalToConstant: 140),
            showResultsButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func buildLeftMenu() {
        for i in 0...3 {
            guard let t = Tab(rawValue: i) else { continue }
            let b = UIButton(type: .system)
            b.setTitle(t.title, for: .normal)
            b.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            b.setTitleColor(.label, for: .normal)
            b.contentHorizontalAlignment = .left
            b.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            b.tag = i
            b.addTarget(self, action: #selector(leftMenuTapped(_:)), for: .touchUpInside)

            // small left background highlight for selected
            b.backgroundColor = (t == selectedTab) ? UIColor.systemGray6 : .clear

            leftMenu.addArrangedSubview(b)
        }
    }

    private func rebuildLeftMenuSelection() {
        for case let b as UIButton in leftMenu.arrangedSubviews {
            b.backgroundColor = (b.tag == selectedTab.rawValue) ? UIColor.systemGray6 : .clear
        }
    }

    // Build each content view once
    private func buildContentViews() {
        // Skills: vertical stack with toggle buttons (multi-select)
        skillsStack.axis = .vertical
        skillsStack.spacing = 12
        skillsStack.alignment = .leading
        skillsStack.translatesAutoresizingMaskIntoConstraints = false

        for s in skillsList {
            let row = makeCheckboxRow(title: s)
            skillsStack.addArrangedSubview(row)
        }

        // Mentor role: radio style (single select)
        mentorRoleStack.axis = .vertical
        mentorRoleStack.spacing = 12
        mentorRoleStack.alignment = .leading
        mentorRoleStack.translatesAutoresizingMaskIntoConstraints = false

        for r in mentorRoles {
            let row = makeRadioRow(title: r, group: .mentorRole)
            mentorRoleStack.addArrangedSubview(row)
        }

        // Experience: radio style
        experienceStack.axis = .vertical
        experienceStack.spacing = 12
        experienceStack.alignment = .leading
        experienceStack.translatesAutoresizingMaskIntoConstraints = false

        for e in experienceOptions {
            let row = makeRadioRow(title: e, group: .experience)
            experienceStack.addArrangedSubview(row)
        }

        // Price: two text fields arranged horizontally
        priceStack.axis = .horizontal
        priceStack.spacing = 12
        priceStack.alignment = .center
        priceStack.translatesAutoresizingMaskIntoConstraints = false
        priceStack.addArrangedSubview(priceMinField)
        priceStack.addArrangedSubview(priceMaxField)

        priceMinField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        priceMaxField.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }

    // MARK: - Content swapping
    private func updateContentForSelectedTab() {
        rebuildLeftMenuSelection()

        // remove existing subviews
        contentContainer.subviews.forEach { $0.removeFromSuperview() }

        switch selectedTab {
        case .skills:
            contentContainer.addSubview(skillsStack)
            NSLayoutConstraint.activate([
                skillsStack.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 20),
                skillsStack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 20),
                skillsStack.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -20)
            ])
        case .mentorRole:
            contentContainer.addSubview(mentorRoleStack)
            NSLayoutConstraint.activate([
                mentorRoleStack.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 20),
                mentorRoleStack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 20),
                mentorRoleStack.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -20)
            ])
        case .experience:
            contentContainer.addSubview(experienceStack)
            NSLayoutConstraint.activate([
                experienceStack.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 20),
                experienceStack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 20),
                experienceStack.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -20)
            ])
        case .price:
            contentContainer.addSubview(priceStack)
            NSLayoutConstraint.activate([
                priceStack.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 28),
                priceStack.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 20)
            ])
        }
    }

    // MARK: - Controls factory
    private func makeCheckboxRow(title: String) -> UIControl {
        let container = UIControl()
        container.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false

        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "square"), for: .normal)
        btn.tintColor = .label
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(skillCheckboxTapped(_:)), for: .touchUpInside)
        btn.accessibilityLabel = title

        container.addSubview(btn)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            btn.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            btn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            btn.widthAnchor.constraint(equalToConstant: 28),
            btn.heightAnchor.constraint(equalToConstant: 28),

            label.leadingAnchor.constraint(equalTo: btn.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    private enum RadioGroup { case mentorRole, experience }
    private func makeRadioRow(title: String, group: RadioGroup) -> UIControl {
        let container = UIControl()
        container.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false

        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "circle"), for: .normal)
        btn.tintColor = .label
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(radioTapped(_:)), for: .touchUpInside)
        btn.accessibilityLabel = title
        // use tag to identify group: 0 for mentorRole, 1 for experience. We'll encode index as accessibilityValue.
        btn.tag = (group == .mentorRole) ? 0 : 1

        container.addSubview(btn)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            btn.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            btn.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            btn.widthAnchor.constraint(equalToConstant: 28),
            btn.heightAnchor.constraint(equalToConstant: 28),

            label.leadingAnchor.constraint(equalTo: btn.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        // store title in accessibilityValue so we can read it back in handler
        btn.accessibilityValue = title
        return container
    }

    // MARK: - Actions
    @objc private func leftMenuTapped(_ sender: UIButton) {
        selectedTab = Tab(rawValue: sender.tag) ?? .skills
    }

    @objc private func skillCheckboxTapped(_ sender: UIButton) {
        guard let title = sender.accessibilityLabel else { return }
        if filters.skills.contains(title) {
            filters.skills.remove(title)
            sender.setImage(UIImage(systemName: "square"), for: .normal)
        } else {
            filters.skills.insert(title)
            sender.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
        }
    }

    @objc private func radioTapped(_ sender: UIButton) {
        guard let title = sender.accessibilityValue else { return }
        if sender.tag == 0 {
            // mentorRole group
            // clear previous visuals
            for case let ctrl as UIControl in mentorRoleStack.arrangedSubviews {
                if let b = ctrl.subviews.compactMap({ $0 as? UIButton }).first {
                    b.setImage(UIImage(systemName: "circle"), for: .normal)
                }
            }
            // set this one
            sender.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .normal)
            filters.mentorRole = title
        } else {
            // experience group
            for case let ctrl as UIControl in experienceStack.arrangedSubviews {
                if let b = ctrl.subviews.compactMap({ $0 as? UIButton }).first {
                    b.setImage(UIImage(systemName: "circle"), for: .normal)
                }
            }
            sender.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .normal)
            filters.experience = title
        }
    }

    @objc private func clearTapped() {
        filters = MentorFilters()
        // reset UI: uncheck checkboxes + radios + price fields
        for case let ctrl as UIControl in skillsStack.arrangedSubviews {
            if let b = ctrl.subviews.compactMap({ $0 as? UIButton }).first {
                b.setImage(UIImage(systemName: "square"), for: .normal)
            }
        }
        for case let ctrl as UIControl in mentorRoleStack.arrangedSubviews {
            if let b = ctrl.subviews.compactMap({ $0 as? UIButton }).first {
                b.setImage(UIImage(systemName: "circle"), for: .normal)
            }
        }
        for case let ctrl as UIControl in experienceStack.arrangedSubviews {
            if let b = ctrl.subviews.compactMap({ $0 as? UIButton }).first {
                b.setImage(UIImage(systemName: "circle"), for: .normal)
            }
        }
        priceMinField.text = ""
        priceMaxField.text = ""
    }

    @objc private func showResultsTapped() {
        // read price fields
        if let minText = priceMinField.text, let min = Int(minText) {
            filters.priceMin = min
        } else {
            filters.priceMin = nil
        }
        if let maxText = priceMaxField.text, let max = Int(maxText) {
            filters.priceMax = max
        } else {
            filters.priceMax = nil
        }

        dismiss(animated: true) {
            self.onApplyFilters?(self.filters)
        }
    }

    // allow tapping outside to dismiss
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        let loc = t.location(in: view)
        if !container.frame.contains(loc) {
            dismiss(animated: true, completion: nil)
        }
    }
}

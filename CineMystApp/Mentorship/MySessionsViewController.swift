//
//  MySessionViewController.swift
//  CineMystApp
//
//  Created by You on Today.
//

import UIKit

// MARK: - Models
struct SessionModel {
    let mentorName: String
    let role: String
    let date: Date
    let imageName: String?
    let rating: Double
}

struct MentorModel {
    let name: String
    let role: String
    let imageName: String?
    let rating: Double
}

// MARK: - SessionCardView (reusable card used in the "My Session" area)
final class SessionCardView: UIView {

    private let container: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemGray6
        v.layer.cornerRadius = 14
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let avatar: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 36
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .systemGray5
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let roleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        l.textAlignment = .right
        return l
    }()

    private let starImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.tintColor = .systemBlue
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let ratingLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var ratingStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [starImageView, ratingLabel])
        s.axis = .horizontal
        s.alignment = .center
        s.spacing = 6
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // init
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        container.addSubview(avatar)
        container.addSubview(nameLabel)
        container.addSubview(roleLabel)
        container.addSubview(dateLabel)
        container.addSubview(ratingStack)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            avatar.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            avatar.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            avatar.widthAnchor.constraint(equalToConstant: 72),
            avatar.heightAnchor.constraint(equalToConstant: 72),

            dateLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            dateLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            dateLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 140),

            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            nameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: ratingStack.leadingAnchor, constant: -8),

            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            roleLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -12),
            roleLabel.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -12),

            ratingStack.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -8),
            ratingStack.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),

            starImageView.widthAnchor.constraint(equalToConstant: 12),
            starImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with model: SessionModel) {
        nameLabel.text = model.mentorName
        roleLabel.text = model.role

        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        dateLabel.text = df.string(from: model.date)

        ratingLabel.text = String(format: "%.1f", model.rating)

        if let name = model.imageName, let img = UIImage(named: name) {
            avatar.image = img
            avatar.contentMode = .scaleAspectFill
        } else {
            let cfg = UIImage.SymbolConfiguration(pointSize: 34, weight: .regular)
            avatar.image = UIImage(systemName: "person.circle.fill", withConfiguration: cfg)
            avatar.tintColor = .systemGray3
            avatar.contentMode = .center
        }
    }
}


// MARK: - MentorCell for collection view
final class MentorCelll: UICollectionViewCell {
    static let reuseIdentifier = "MentorCellSmall"

    private let card: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 12
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.06
        v.layer.shadowOffset = CGSize(width: 0, height: 6)
        v.layer.shadowRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.backgroundColor = .systemGray5
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let roleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let starImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.tintColor = .systemBlue
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let ratingLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var ratingStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [starImageView, ratingLabel])
        s.axis = .horizontal
        s.spacing = 6
        s.alignment = .center
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(card)
        card.addSubview(imageView)
        card.addSubview(nameLabel)
        card.addSubview(roleLabel)
        card.addSubview(ratingStack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
            imageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            imageView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.55),

            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),

            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            roleLabel.bottomAnchor.constraint(lessThanOrEqualTo: card.bottomAnchor, constant: -12),

            ratingStack.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            ratingStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

            starImageView.widthAnchor.constraint(equalToConstant: 12),
            starImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with m: MentorModel) {
        nameLabel.text = m.name
        roleLabel.text = m.role
        ratingLabel.text = String(format: "%.1f", m.rating)
        if let n = m.imageName, let img = UIImage(named: n) {
            imageView.image = img
            imageView.contentMode = .scaleAspectFill
        } else {
            imageView.image = UIImage(systemName: "person.crop.rectangle")
            imageView.tintColor = .systemGray3
            imageView.contentMode = .center
        }
    }
}


// MARK: - MySessionViewController
final class MySessionViewController: UIViewController {

    // theme
    private let plum = UIColor(red: 0x43/255, green: 0x16/255, blue: 0x31/255, alpha: 1)

    // UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Mentorship"
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Discover & learn from your mentor"
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Mentee", "Mentor"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentTintColor = .white
        sc.backgroundColor = UIColor.systemGray5
        sc.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .normal)
        sc.layer.cornerRadius = 18
        sc.layer.masksToBounds = true
        return sc
    }()

    // "My Session" header row
    private let mySessionHeader: UILabel = {
        let l = UILabel()
        l.text = "My Session"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let seeAllButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("See all", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // stack holding session cards
    private let sessionsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 14
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    // mentors header
    private let mentorsHeader: UILabel = {
        let l = UILabel()
        l.text = "Mentors"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let mentorsSeeAllButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("See all", for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // mentors collection
    private lazy var mentorsCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 24, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(MentorCell.self, forCellWithReuseIdentifier: MentorCell.reuseIdentifier)
        return cv
    }()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // Data
    private var sessions: [SessionModel] = []
    private var mentors: [MentorModel] = []

    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        titleLabel.textColor = plum

        setupViews()
        setupConstraints()
        setupData()
        mentorsCollection.dataSource = self
        mentorsCollection.delegate = self

        // actions
        seeAllButton.addTarget(self, action: #selector(didTapSeeAllSessions), for: .touchUpInside)
        mentorsSeeAllButton.addTarget(self, action: #selector(didTapSeeAllMentors), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ensure tab bar visible
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - setup
    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(segmentControl)

        contentView.addSubview(mySessionHeader)
        contentView.addSubview(seeAllButton)
        contentView.addSubview(sessionsStack)

        contentView.addSubview(mentorsHeader)
        contentView.addSubview(mentorsSeeAllButton)
        contentView.addSubview(mentorsCollection)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // scroll
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            // header
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            segmentControl.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            segmentControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            segmentControl.widthAnchor.constraint(equalToConstant: 220),
            segmentControl.heightAnchor.constraint(equalToConstant: 36),

            // My Session header
            mySessionHeader.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 24),
            mySessionHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            seeAllButton.centerYAnchor.constraint(equalTo: mySessionHeader.centerYAnchor),
            seeAllButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // sessions stack
            sessionsStack.topAnchor.constraint(equalTo: mySessionHeader.bottomAnchor, constant: 12),
            sessionsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            sessionsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            // mentors
            mentorsHeader.topAnchor.constraint(equalTo: sessionsStack.bottomAnchor, constant: 24),
            mentorsHeader.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            mentorsSeeAllButton.centerYAnchor.constraint(equalTo: mentorsHeader.centerYAnchor),
            mentorsSeeAllButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            mentorsCollection.topAnchor.constraint(equalTo: mentorsHeader.bottomAnchor, constant: 12),
            mentorsCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mentorsCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mentorsCollection.heightAnchor.constraint(equalToConstant: 420), // enough height for two rows
            mentorsCollection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    private func setupData() {
        let cal = Calendar.current
        let now = Date()
        let d1 = cal.date(byAdding: .day, value: 3, to: now) ?? now
        let d2 = cal.date(byAdding: .day, value: 7, to: now) ?? now

        sessions = [
            SessionModel(mentorName: "Amit Sawi", role: "Senior Director", date: d1, imageName: "Image", rating: 4.8),
            SessionModel(mentorName: "Amit Sawi", role: "Senior Director", date: d2, imageName: "Image", rating: 4.8)
        ]

        mentors = [
            MentorModel(name: "Nathan Hales", role: "Actor", imageName: "Image", rating: 4.9),
            MentorModel(name: "Ava Johnson", role: "Casting Director", imageName: "Image", rating: 4.8)
        ]

        // Populate sessions stack with card views
        sessionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for s in sessions {
            let card = SessionCardView()
            card.configure(with: s)
            // give a fixed height visually similar to screenshot
            NSLayoutConstraint.activate([
                card.heightAnchor.constraint(equalToConstant: 96)
            ])
            sessionsStack.addArrangedSubview(card)

            // add tap recognizer to each card (if you want navigation)
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapSessionCard(_:)))
            card.addGestureRecognizer(tap)
            card.isUserInteractionEnabled = true
        }

        mentorsCollection.reloadData()
    }

    // MARK: - Actions
    @objc private func didTapSeeAllSessions() {
        // implement see all sessions (push a full screen list if required)
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = "All Sessions"
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func didTapSeeAllMentors() {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = "All Mentors"
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func didTapSessionCard(_ g: UITapGestureRecognizer) {
        guard let card = g.view as? SessionCardView else { return }
        // push a detail or open the booked session — for now push a simple VC
        let detail = UIViewController()
        detail.view.backgroundColor = .systemBackground
        detail.title = "Session Detail"
        navigationController?.pushViewController(detail, animated: true)
    }
}

// MARK: - Collection datasource & delegate
extension MySessionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mentors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let c = collectionView.dequeueReusableCell(withReuseIdentifier: MentorCelll.reuseIdentifier, for: indexPath) as? MentorCelll else {
            return UICollectionViewCell()
        }
        c.configure(with: mentors[indexPath.item])
        return c
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let m = mentors[indexPath.item]
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = m.name
        navigationController?.pushViewController(vc, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let layout = collectionViewLayout as? UICollectionViewFlowLayout
        let insets = layout?.sectionInset.left ?? 16 + (layout?.sectionInset.right ?? 16)
        let spacing = layout?.minimumInteritemSpacing ?? 12
        let width = floor((collectionView.bounds.width - insets - spacing) / 2.0)
        return CGSize(width: width - 4, height: 180)
    }
}

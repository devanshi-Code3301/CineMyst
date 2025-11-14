//
// PostBookingMentorshipViewController.swift
// Shows "My Session" above Mentors; reads sessions from SessionStore.
//

import UIKit

final class PostBookingMentorshipViewController: UIViewController {

    private let plum = UIColor(red: 0x43/255, green: 0x16/255, blue: 0x31/255, alpha: 1)

    // Header
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Mentorship"
        l.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Discover & learn from your mentor"
        l.font = UIFont.systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private lazy var segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Mentee", "Mentor"])
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = .white
        sc.backgroundColor = UIColor.systemGray5
        sc.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14, weight: .semibold)], for: .normal)
        sc.layer.cornerRadius = 18
        sc.layer.masksToBounds = true
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    // My Session
    private let sessionsTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "My Session"
        l.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let sessionsSeeAllButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("See all", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private lazy var sessionsTableView: UITableView = {
        let tv = UITableView()
        tv.register(SessionCell.self, forCellReuseIdentifier: SessionCell.reuseIdentifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.estimatedRowHeight = 92
        tv.rowHeight = UITableView.automaticDimension
        return tv
    }()

    // Mentors (reuse MentorCell)
    private let mentorsLabel: UILabel = {
        let l = UILabel()
        l.text = "Mentors"
        l.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let mentorsSeeAllButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("See all", for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(MentorCell.self, forCellWithReuseIdentifier: MentorCell.reuseIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        return cv
    }()

    // data
    private var sessions: [Session] = []
    private var mentors: [Mentor] = [
        Mentor(name: "Nathan Hales", role: "Actor", rating: 4.9, imageName: "Image"),
        Mentor(name: "Ava Johnson", role: "Casting Director", rating: 4.8, imageName: "Image"),
        Mentor(name: "Maya Patel", role: "Actor", rating: 5.0, imageName: "Image"),
        Mentor(name: "Riya Sharma", role: "Actor", rating: 4.9, imageName: "Image")
    ]

    private var sessionsTableHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        titleLabel.textColor = plum

        setupHierarchy()
        setupConstraints()
        wireDelegates()

        sessions = SessionStore.shared.all()
        updateSessionsLayout()
        print("[PostBookingMentorship] viewDidLoad sessionsCount=\(sessions.count)")

        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveSessionNotification(_:)), name: .sessionUpdated, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .sessionUpdated, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadSessions()
    }

    private func setupHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(segmentControl)

        view.addSubview(sessionsTitleLabel)
        view.addSubview(sessionsSeeAllButton)
        view.addSubview(sessionsTableView)

        view.addSubview(mentorsLabel)
        view.addSubview(mentorsSeeAllButton)
        view.addSubview(collectionView)
    }

    private func setupConstraints() {
        let pad: CGFloat = 20
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            segmentControl.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 18),
            segmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            segmentControl.widthAnchor.constraint(equalToConstant: 220),
            segmentControl.heightAnchor.constraint(equalToConstant: 36),

            sessionsTitleLabel.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 18),
            sessionsTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),

            sessionsSeeAllButton.centerYAnchor.constraint(equalTo: sessionsTitleLabel.centerYAnchor),
            sessionsSeeAllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),

            sessionsTableView.topAnchor.constraint(equalTo: sessionsTitleLabel.bottomAnchor, constant: 12),
            sessionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),
            sessionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),

            mentorsLabel.topAnchor.constraint(equalTo: sessionsTableView.bottomAnchor, constant: 22),
            mentorsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),

            mentorsSeeAllButton.centerYAnchor.constraint(equalTo: mentorsLabel.centerYAnchor),
            mentorsSeeAllButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),

            collectionView.topAnchor.constraint(equalTo: mentorsLabel.bottomAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        sessionsTableHeightConstraint = sessionsTableView.heightAnchor.constraint(equalToConstant: 0)
        sessionsTableHeightConstraint.isActive = true
    }

    private func wireDelegates() {
        sessionsTableView.dataSource = self
        sessionsTableView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self

        sessionsSeeAllButton.addTarget(self, action: #selector(didTapSessionsSeeAll), for: .touchUpInside)
        mentorsSeeAllButton.addTarget(self, action: #selector(didTapMentorsSeeAll), for: .touchUpInside)
    }

    // MARK: actions
    @objc private func didReceiveSessionNotification(_ n: Notification) {
        print("[PostBookingMentorship] received sessionUpdated: \(n.userInfo ?? [:])")
        reloadSessions()
    }

    func reloadSessions() {
        sessions = SessionStore.shared.all()
        print("[PostBookingMentorship] reloadSessions -> sessions.count = \(sessions.count)")
        updateSessionsLayout()
    }

    private func updateSessionsLayout() {
        DispatchQueue.main.async {
            self.sessionsTableView.reloadData()
            self.sessionsTableView.layoutIfNeeded()
            let h = self.sessionsTableView.contentSize.height
            self.sessionsTableHeightConstraint.constant = h
            UIView.animate(withDuration: 0.18) { self.view.layoutIfNeeded() }
        }
    }

    @objc private func segmentChanged(_ s: UISegmentedControl) { /* no-op for now */ }
    @objc private func didTapSessionsSeeAll() { print("Sessions See all tapped") }
    @objc private func didTapMentorsSeeAll() {
        let vc = AllMentorsViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension PostBookingMentorshipViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int { sessions.count }

    func tableView(_ tv: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tv.dequeueReusableCell(withIdentifier: SessionCell.reuseIdentifier, for: indexPath) as? SessionCell else {
            return UITableViewCell()
        }
        let s = sessions[indexPath.row]
        cell.configure(with: s)
        return cell
    }

    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        tv.deselectRow(at: indexPath, animated: true)
        let s = sessions[indexPath.row]
        let detailVC = SessionDetailViewController()
        detailVC.session = s
        detailVC.hidesBottomBarWhenPushed = false
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension PostBookingMentorshipViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int { mentors.count }

    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let c = cv.dequeueReusableCell(withReuseIdentifier: MentorCell.reuseIdentifier, for: indexPath) as? MentorCell else {
            return UICollectionViewCell()
        }
        c.configure(with: mentors[indexPath.item])
        return c
    }

    func collectionView(_ cv: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 160, height: 170)
        }
        let insets = layout.sectionInset.left + layout.sectionInset.right
        let spacing = layout.minimumInteritemSpacing
        let width = floor((cv.bounds.width - insets - spacing) / 2.0)
        return CGSize(width: width, height: width * 0.85)
    }

    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mentor = mentors[indexPath.item]
        let vc = BookViewController()
        vc.mentor = mentor
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

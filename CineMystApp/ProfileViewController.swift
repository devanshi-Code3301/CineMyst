//
//  ProfileViewController.swift
//  CineMystApp
//
//  Created by Devanshi on 11/11/25.
//

import UIKit

final class ProfileViewController: UIViewController {

    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let coverLabel = UILabel()
    private let profileImageView = UIImageView()
    private let verifiedBadge = UIImageView()

    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let connectionsLabel = UILabel()

    private let connectButton = UIButton(type: .system)
    private let portfolioButton = UIButton(type: .system)

    private let aboutTitle = UILabel()
    private let aboutText = UILabel()

    private let locationIcon = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
    private let experienceIcon = UIImageView(image: UIImage(systemName: "briefcase"))
    private let locationLabel = UILabel()
    private let experienceLabel = UILabel()

    private let segmentControl = UISegmentedControl(items: ["Gallery", "Flicks", "Tagged"])
    private let collectionView: UICollectionView

    private var galleryImages = ["rani1", "rani2", "rani3", "rani4", "rani5", "rani6"]

    // MARK: - Init
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        hidesBottomBarWhenPushed = true // ✅ hides tab bar for this screen

        setupNavigationBar()
        setupScrollView()
        setupUI()
        layoutUI()
    }

    // MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        navigationItem.title = "" // ✅ no "Rani HBO" on top
        navigationItem.backButtonTitle = "" // back arrow only

        // ✅ Make sure navigation bar looks solid white and not translucent
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = .systemBackground
    }

    // MARK: - Setup Scroll View
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - Setup UI
    private func setupUI() {
        // Header / Cover
        coverLabel.text = "Acting for Life"
        coverLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        coverLabel.textAlignment = .center

        // Profile
        profileImageView.image = UIImage(named: "rani_profile")
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.translatesAutoresizingMaskIntoConstraints = false

        // ✅ Remove “+” symbol from status area
        verifiedBadge.image = UIImage(systemName: "checkmark.seal.fill")
        verifiedBadge.tintColor = UIColor.systemBlue
        verifiedBadge.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.text = "Rani HBO"
        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        nameLabel.textAlignment = .center

        usernameLabel.text = "@raniaf234 • Professional Actor"
        usernameLabel.font = .systemFont(ofSize: 13)
        usernameLabel.textColor = .secondaryLabel
        usernameLabel.textAlignment = .center

        connectionsLabel.text = "1.2K Connections"
        connectionsLabel.font = .systemFont(ofSize: 14, weight: .medium)
        connectionsLabel.textAlignment = .center
        connectionsLabel.textColor = .secondaryLabel

        // Buttons
        connectButton.setTitle("Connected", for: .normal)
        connectButton.backgroundColor = UIColor(named: "AccentColor")

        connectButton.setTitleColor(.white, for: .normal)
        connectButton.layer.cornerRadius = 10
        connectButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)

        portfolioButton.setTitle("View Portfolio", for: .normal)
        portfolioButton.backgroundColor = UIColor(named: "AccentColor")

        portfolioButton.setTitleColor(.white, for: .normal)
        portfolioButton.layer.cornerRadius = 10
        portfolioButton.layer.shadowOpacity = 0.2
        portfolioButton.layer.shadowRadius = 2
        portfolioButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        portfolioButton.addTarget(self, action: #selector(openPortfolio), for: .touchUpInside)

        // About
        aboutTitle.text = "About"
        aboutTitle.font = .systemFont(ofSize: 17, weight: .semibold)

        aboutText.text = """
        Professional actor with 10+ years of experience in theater, film, and television. Passionate about storytelling and bringing characters to life.
        """
        aboutText.numberOfLines = 0
        aboutText.font = .systemFont(ofSize: 14)

        // Location & Experience
        locationIcon.tintColor = .label
        experienceIcon.tintColor = .label

        locationLabel.text = "Mumbai, India"
        locationLabel.font = .systemFont(ofSize: 13)

        experienceLabel.text = "10+ years"
        experienceLabel.font = .systemFont(ofSize: 13)

        // Segmented Control
        segmentControl.selectedSegmentIndex = 0
        segmentControl.backgroundColor = .clear
        segmentControl.selectedSegmentTintColor = .clear
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.systemPurple, .font: UIFont.boldSystemFont(ofSize: 15)], for: .selected)
        segmentControl.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)

        // Collection View
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: "GalleryCell")

        // Add to hierarchy
        [coverLabel, profileImageView, verifiedBadge, nameLabel, usernameLabel, connectionsLabel,
         connectButton, portfolioButton, aboutTitle, aboutText, locationIcon, experienceIcon,
         locationLabel, experienceLabel, segmentControl, collectionView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }

    // MARK: - Layout
    private func layoutUI() {
        NSLayoutConstraint.activate([
            coverLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            coverLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            profileImageView.topAnchor.constraint(equalTo: coverLabel.bottomAnchor, constant: 16),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            verifiedBadge.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 6),
            verifiedBadge.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 2),
            verifiedBadge.widthAnchor.constraint(equalToConstant: 20),
            verifiedBadge.heightAnchor.constraint(equalToConstant: 20),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            usernameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            connectionsLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 6),
            connectionsLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            connectButton.topAnchor.constraint(equalTo: connectionsLabel.bottomAnchor, constant: 16),
            connectButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            connectButton.widthAnchor.constraint(equalToConstant: 140),
            connectButton.heightAnchor.constraint(equalToConstant: 38),

            portfolioButton.centerYAnchor.constraint(equalTo: connectButton.centerYAnchor),
            portfolioButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            portfolioButton.widthAnchor.constraint(equalToConstant: 140),
            portfolioButton.heightAnchor.constraint(equalToConstant: 38),

            aboutTitle.topAnchor.constraint(equalTo: connectButton.bottomAnchor, constant: 30),
            aboutTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            aboutText.topAnchor.constraint(equalTo: aboutTitle.bottomAnchor, constant: 6),
            aboutText.leadingAnchor.constraint(equalTo: aboutTitle.leadingAnchor),
            aboutText.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            locationIcon.topAnchor.constraint(equalTo: aboutText.bottomAnchor, constant: 16),
            locationIcon.leadingAnchor.constraint(equalTo: aboutText.leadingAnchor),
            locationIcon.widthAnchor.constraint(equalToConstant: 16),
            locationIcon.heightAnchor.constraint(equalToConstant: 16),

            locationLabel.centerYAnchor.constraint(equalTo: locationIcon.centerYAnchor),
            locationLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor, constant: 6),

            experienceIcon.centerYAnchor.constraint(equalTo: locationIcon.centerYAnchor),
            experienceIcon.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -10),
            experienceIcon.widthAnchor.constraint(equalToConstant: 16),
            experienceIcon.heightAnchor.constraint(equalToConstant: 16),

            experienceLabel.centerYAnchor.constraint(equalTo: experienceIcon.centerYAnchor),
            experienceLabel.leadingAnchor.constraint(equalTo: experienceIcon.trailingAnchor, constant: 6),

            segmentControl.topAnchor.constraint(equalTo: locationIcon.bottomAnchor, constant: 24),
            segmentControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            collectionView.heightAnchor.constraint(equalToConstant: 600),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Navigation
    @objc private func openPortfolio() {
        let portfolioVC = PortfolioViewController()
        portfolioVC.hidesBottomBarWhenPushed = true // ✅ no tab bar there either
        navigationController?.pushViewController(portfolioVC, animated: true)
    }
}

// MARK: - UICollectionView
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        galleryImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        cell.configure(imageName: galleryImages[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 6) / 3
        return CGSize(width: width, height: width)
    }
}

// MARK: - Gallery Cell

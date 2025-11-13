//
//  PaymentConfirmationViewController.swift
//  CineMystApp
//
//  Created by You on Today.
//

import UIKit

final class PaymentConfirmationViewController: UIViewController {

    // MARK: - Public callback
    /// Called when user taps Done. The presenting controller can pass a handler to perform navigation.
    var onDone: (() -> Void)?

    // MARK: - UI
    private let dimView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0, alpha: 0.45)
        v.alpha = 0
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 20
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let checkBox: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.94, green: 0.9, blue: 0.98, alpha: 1)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let checkImage: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark"))
        iv.tintColor = UIColor(red: 0.4, green: 0.15, blue: 0.31, alpha: 1)
        iv.contentMode = .center
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Your payment has been done!"
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "We've sent you a confirmation mail."
        l.font = .systemFont(ofSize: 14)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let doneButton: UIButton = {
        var c = UIButton.Configuration.filled()
        c.cornerStyle = .capsule
        c.title = "Done"
        c.baseBackgroundColor = UIColor(red: 0x43/255.0, green: 0x16/255.0, blue: 0x31/255.0, alpha: 1)
        c.baseForegroundColor = .white
        let b = UIButton(configuration: c)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return b
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve

        view.backgroundColor = .clear
        setupViews()
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)

        // tap outside to dismiss (optional)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dimTapped(_:)))
        dimView.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateIn()
    }

    // MARK: - Layout
    private func setupViews() {
        view.addSubview(dimView)
        view.addSubview(cardView)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.widthAnchor.constraint(lessThanOrEqualToConstant: 320),
            cardView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            cardView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])

        // Build content inside card
        cardView.addSubview(checkBox)
        checkBox.addSubview(checkImage)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(doneButton)

        NSLayoutConstraint.activate([
            checkBox.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            checkBox.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            checkBox.widthAnchor.constraint(equalToConstant: 48),
            checkBox.heightAnchor.constraint(equalToConstant: 48),

            checkImage.centerXAnchor.constraint(equalTo: checkBox.centerXAnchor),
            checkImage.centerYAnchor.constraint(equalTo: checkBox.centerYAnchor),
            checkImage.widthAnchor.constraint(equalToConstant: 18),
            checkImage.heightAnchor.constraint(equalToConstant: 18),

            titleLabel.topAnchor.constraint(equalTo: checkBox.bottomAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),

            doneButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 18),
            doneButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 48),
            doneButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -48),
            doneButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Animations
    private func animateIn() {
        cardView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92).concatenating(CGAffineTransform(translationX: 0, y: 20))
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
            self.dimView.alpha = 1.0
        }
        UIView.animate(withDuration: 0.32, delay: 0.06, usingSpringWithDamping: 0.82, initialSpringVelocity: 0.8, options: []) {
            self.cardView.transform = .identity
        }
    }

    private func animateOut(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.18, animations: {
            self.cardView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96).concatenating(CGAffineTransform(translationX: 0, y: 8))
            self.dimView.alpha = 0
            self.cardView.alpha = 0
        }) { _ in
            completion?()
        }
    }

    // MARK: - Actions
    @objc private func didTapDone() {
        animateOut {
            self.dismiss(animated: false) {
                self.onDone?()
            }
        }
    }

    @objc private func dimTapped(_ g: UITapGestureRecognizer) {
        // optional: dismiss on background tap
        animateOut {
            self.dismiss(animated: false) {
                self.onDone?()
            }
        }
    }
}

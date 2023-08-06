//
//  CollectionActivityIndicatorView.swift
//  ImageSearch
//
//  Created by andrey.marshak on 07.08.2023.
//

import UIKit

class CollectionActivityIndicatorView: UICollectionReusableView {
    static let ElementKind = "CollectionActivityIndicatorView"

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            activityIndicator.leadingAnchor.constraint(
                greaterThanOrEqualToSystemSpacingAfter: leadingAnchor,
                multiplier: 1
            )
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating() {
        activityIndicator.startAnimating()
    }

    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}

class CollectionActivityIndicatorCell: UICollectionViewCell {
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            activityIndicator.leadingAnchor.constraint(
                greaterThanOrEqualToSystemSpacingAfter: leadingAnchor,
                multiplier: 1
            )
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

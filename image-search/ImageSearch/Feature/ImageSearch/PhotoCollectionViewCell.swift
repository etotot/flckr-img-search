//
//  PhotoCollectionViewCell.swift
//  ImageSearch
//
//  Created by andrey.marshak on 06.08.2023.
//

import UIKit
import NukeUI

class PhotoCollectionViewCell: UICollectionViewCell {
    lazy var imageView: LazyImageView = {
        let imageView = LazyImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UICollectionViewCell

    override func prepareForReuse() {
        imageView.url = nil
    }
}

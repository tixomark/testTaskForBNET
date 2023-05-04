//
//  ItemCell.swift
//  testTask
//
//  Created by tixomark on 4/29/23.
//

import UIKit

final class ItemCell: UICollectionViewCell {
    var imageView: UIImageView!
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = ""
        descriptionLabel.text = ""
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpConstraints()
    }
    
    private func setUpCell() {
        backgroundColor = .TTsystemColor
        layer.cornerRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.2
        
        imageView = UIImageView()
        titleLabel = UILabel()
        descriptionLabel = UILabel()
        
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 13)
        
        descriptionLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
        descriptionLabel.textColor = .systemGray
        descriptionLabel.numberOfLines = 5
    }
    
    private func setUpConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -12),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.6),
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -12),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
        ])
    }
    
    func configureUsing(_ item: Item) {
        imageView.backgroundColor = .systemGray
        titleLabel.text = item.name
        descriptionLabel.text = item.description
        var itemImage: UIImage!
        
        guard let imagePath = item.imageURL, let imageURL = URL(string: imagePath) else {
            print("Can not create image URL")
            itemImage = UIImage(named: "noImage")
            return
        }
        do {
            let data = try Data(contentsOf: imageURL)
            if let image = UIImage(data: data) {
                itemImage = image
            }
        } catch {
            print("No image for item")
            itemImage = UIImage(named: "noImage")
        }
        imageView.image = itemImage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

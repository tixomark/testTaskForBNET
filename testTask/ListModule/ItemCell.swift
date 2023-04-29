//
//  ItemCell.swift
//  testTask
//
//  Created by tixomark on 4/29/23.
//

import UIKit

class ItemCell: UICollectionViewCell {
    var imageView: UIImageView!
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpCell()

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpCellAppearance()
    }
    
    func setUpCell() {
        imageView = UIImageView()
        titleLabel = UILabel()
        descriptionLabel = UILabel()
        
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont(name: "SanFranciscoDisplay-Semibold", size: 13)
        
        descriptionLabel.font = UIFont(name: "SanFranciscoDisplay-Regular", size: 12)
        descriptionLabel.numberOfLines = 5
        
        
        
    }
    
    func setUpCellAppearance() {
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
            titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: 12),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor)
        ])
        
        
    }
    
    func setUpCellData() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

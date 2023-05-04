//
//  ItemDetailViewController.swift
//  testTask
//
//  Created by tixomark on 4/29/23.
//

import UIKit

final class ItemDetailViewController: UIViewController {
    var presenter: ItemDetailPresenterProtocol!
    
    var mainImageView, categoryIconImageView, ratingImageView: UIImageView!
    var itemNameLabel, itemDetailLabel: UILabel!
    var whereToBuyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
        presenter.requestDataUpdate()
        presenter.getCategoryIcon()
    }
    
    deinit {
        print("deinited ItemDetailViewController")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setUpConstraints()
    }
    
    private func setUp() {
        view.backgroundColor = .TTsystemColor
        
        mainImageView = UIImageView()
        categoryIconImageView = UIImageView()
        ratingImageView = UIImageView()
        itemNameLabel = UILabel()
        itemDetailLabel = UILabel()
        whereToBuyButton = UIButton()
        view.addSubview(mainImageView)
        view.addSubview(categoryIconImageView)
        view.addSubview(ratingImageView)
        view.addSubview(itemNameLabel)
        view.addSubview(itemDetailLabel)
        view.addSubview(whereToBuyButton)
        
        mainImageView.contentMode = .scaleAspectFit
        mainImageView.clipsToBounds = true
        
        categoryIconImageView.contentMode = .scaleAspectFit
        categoryIconImageView.clipsToBounds = true
        
        itemNameLabel.font = UIFont(name: "AppleSDGothicNeo-Semibold", size: 20)
        itemNameLabel.numberOfLines = 0
        
        itemDetailLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 15)
        itemDetailLabel.textColor = .systemGray
        
        itemDetailLabel.numberOfLines = 0
        
        whereToBuyButton.layer.cornerRadius = 8
        whereToBuyButton.layer.borderWidth = 1
        whereToBuyButton.layer.borderColor = UIColor(red: 239/255,
                                                     green: 239/255,
                                                     blue: 240/255,
                                                     alpha: 1.0).cgColor
        let title = NSAttributedString(string: "ГДЕ КУПИТЬ",
                                       attributes: [.font: UIFont(name: "AppleSDGothicNeo-Regular",
                                                                  size: 12)!])
        whereToBuyButton.setAttributedTitle(title, for: .normal)
        whereToBuyButton.setTitleColor(.TTContrastColor, for: .normal)
        whereToBuyButton.setImage(UIImage(named: "LocationIcon"), for: .normal)
        whereToBuyButton.imageEdgeInsets = UIEdgeInsets(top: 9, left: 0, bottom: 9, right: 7)
        whereToBuyButton.imageView?.contentMode = .scaleAspectFill
    }
    
    private func setUpConstraints() {
        mainImageView.translatesAutoresizingMaskIntoConstraints = false
        categoryIconImageView.translatesAutoresizingMaskIntoConstraints = false
        ratingImageView.translatesAutoresizingMaskIntoConstraints = false
        itemNameLabel.translatesAutoresizingMaskIntoConstraints = false
        itemDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        whereToBuyButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            mainImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainImageView.widthAnchor.constraint(equalToConstant: view.frame.width / 3),
            mainImageView.heightAnchor.constraint(equalToConstant: view.frame.width / 2),
            mainImageView.bottomAnchor.constraint(equalTo: itemNameLabel.topAnchor, constant: -32),
            
            categoryIconImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            categoryIconImageView.topAnchor.constraint(equalTo: mainImageView.topAnchor),
            categoryIconImageView.heightAnchor.constraint(equalToConstant: view.frame.width / 12),
            categoryIconImageView.widthAnchor.constraint(equalTo: categoryIconImageView.heightAnchor),
            
            ratingImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            ratingImageView.topAnchor.constraint(equalTo: mainImageView.topAnchor),
            ratingImageView.heightAnchor.constraint(equalToConstant: view.frame.width / 12),
            ratingImageView.widthAnchor.constraint(equalTo: categoryIconImageView.heightAnchor),
            
            itemNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            itemNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            itemNameLabel.bottomAnchor.constraint(equalTo: itemDetailLabel.topAnchor, constant: -8),
            
            itemDetailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            itemDetailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            itemDetailLabel.bottomAnchor.constraint(equalTo: whereToBuyButton.topAnchor, constant: -16),
            
            whereToBuyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            whereToBuyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            whereToBuyButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
}

extension ItemDetailViewController: ItemDetailViewProtocol {
    func updateUIUsing(_ item: Item) {
        ratingImageView.image = UIImage(named: "StarImage")
        itemNameLabel.text = item.name
        itemDetailLabel.text = item.description
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
        mainImageView.image = itemImage
    }
    
    func updateCategoriesIcon(_ iconUrl: String) {
        var iconImage: UIImage!
        
        guard let iconURL = URL(string: iconUrl) else {
            print("Can not create image URL")
            iconImage = UIImage(named: "noImage")
            return
        }
        do {
            let data = try Data(contentsOf: iconURL)
            if let image = UIImage(data: data) {
                iconImage = image
            }
        } catch {
            print("No image for item")
            iconImage = UIImage(named: "noImage")
        }
        
        DispatchQueue.main.async {
            self.categoryIconImageView.image = iconImage
        }
    }
}

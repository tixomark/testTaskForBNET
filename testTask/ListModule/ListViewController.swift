//
//  ListViewController.swift
//  testTask
//
//  Created by tixomark on 4/28/23.
//

import UIKit

final class ListViewController: UIViewController {
    var presenter: ListPresenterProtocol!
    
    var collectionView: UICollectionView!
    var collectionIsWaitingForUpdate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUp()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: "\(ItemCell.self)")
        
//        presenter.requestCollectionUpdate()
    }
    
    deinit {
        print("deinited ListItemViewController")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setUpConstraints()
    }
    
    
    func setUp() {
        view.backgroundColor = .TTsystemColor
        title = "Препараты"
        
        let flowLayout = UICollectionViewFlowLayout()
        let itemWidth = (view.frame.width - 16 * 2 - 15) / 2
        let itemHeight = itemWidth * 1.8
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
//        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.sectionInset = UIEdgeInsets(top: 24, left: 16, bottom: 56, right: 16)
        flowLayout.minimumLineSpacing = 15
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.addSubview(collectionView)
    }
    
    func setUpConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
}

extension ListViewController: ListViewProtocol {
    func reloadItem(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        DispatchQueue.main.async {
            print("reloading item \(index)")
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func addItemsAt(_ indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            self.collectionView.insertItems(at: indexPaths)
            print("items inserted")
            if indexPaths.count == 10 {
                self.collectionIsWaitingForUpdate = false
            }
        }
    }
    
}

extension ListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.getNumberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(ItemCell.self)", for: indexPath) as! ItemCell
        guard let item = presenter.requestDataForItem(at: indexPath) else {
            return cell
        }
        cell.configureUsing(item)
        
        return cell
    }
}

extension ListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didTapOnItem(at: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !collectionIsWaitingForUpdate else {
//            print("collection is waiting for next batch of items")
            return
        }
        if scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height {
            print("new batch of items is requested")
            presenter.requestNetSetOfItems()
            collectionIsWaitingForUpdate = true
        }
    }
}

//
//  ListViewController.swift
//  testTask
//
//  Created by tixomark on 4/28/23.
//

import UIKit

// Судя по всему, стандартный скролл(а значит и колекшн) не передает ивенты следующему респондеру, даже если нажатие случилось на месте где ничего нет. Был выбор либо сделать тапГесчерРекогнайзер либо переопределить тачесБигэн в наследнике. Второе смотрится лаконичнее.
class TTCollectionView: UICollectionView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        next?.touchesBegan(touches, with: event)
    }
}

final class ListViewController: UIViewController {
    var presenter: ListPresenterProtocol!
    
    var collectionView: TTCollectionView!
    var collectionIsWaitingForUpdate: Bool = false
    var searchButton: UIBarButtonItem!
    var searchBar: UISearchBar!
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: "\(ItemCell.self)")
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
        
        collectionView = TTCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.addSubview(collectionView)
        
        searchButton = UIBarButtonItem(image: UIImage(named: "SearchIcon"), style: .plain, target: self, action: #selector(didTapOnSearchButton(_:)))
        navigationItem.rightBarButtonItem = searchButton
        
        searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.showsCancelButton = false
    }
    
    func setUpConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
    
    @objc func didTapOnSearchButton(_ sender: UIBarButtonItem) {
        searchBar.delegate = self
        navigationItem.setRightBarButton(nil, animated: true)
        navigationItem.titleView = searchBar
        collectionView.setContentOffset(.zero, animated: true)
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
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
    
    func reloadCollection() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            if self.collectionView.isDecelerating || self.collectionView.isDragging {
                
            }
            self.collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
}

extension ListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getNumberOfItems()
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
            return
        }
        if scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height {
            print("new batch of items is requested")
            presenter.requestNetSetOfItems(text: searchBar.text ?? "")
            collectionIsWaitingForUpdate = true
        }
    }
}

extension ListViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            searchBar.text = ""
            searchBar.delegate?.searchBar?(searchBar, textDidChange: "")
        }
        searchBar.setShowsCancelButton(false, animated: true)
        navigationItem.titleView = nil
        navigationItem.rightBarButtonItem = searchButton
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        тут таймер потому, что не хочется на каждое изменение слова !сразу! дулать запросы. Пусть юзер введет хоть что-то более менее завершенное.
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        timer = Timer(timeInterval: 0.2, repeats: false, block: { [weak self] _ in
            self?.presenter.requestNetSetOfItems(text: searchText)
            self?.timer.invalidate()
            self?.timer = nil
        })
        timer.tolerance = 0.02
        RunLoop.current.add(timer, forMode: .common)
    }
}

//
//  ViewController.swift
//  TicTacToe
//
//  Created by Andrew_Alekseyuk on 15.04.22.
//

import UIKit
import TinyConstraints
import RxSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentContainer: UIView!
    @IBOutlet weak var informationLabel: UILabel!
    
    var dimension = 3
    var currentUser: Int = 0 {
        didSet {
            switch currentUser {
            case 0:
                informationLabel.text = "next Cross"
            case 1 :
                informationLabel.text = "next Circle"
            default:
                informationLabel.text = "error"
            }
        }
    }
    var segmentedControl: UISegmentedControl!
    var viewModel: ViewModel!
    let checkMessage = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ViewModel(viewController: self)
        setUpSubscription()
        setUpViews()
    }
    
    private func setUpSubscription() {
        _ =  viewModel.winnerMessage
            .subscribe( onNext: { winner in
                self.showAlert(winner: winner)
            })
    }
    
    private func setUpViews() {
        let items = ["3x3", "4x4", "6x6"]
        segmentedControl = UISegmentedControl(items : items)
        segmentedControl.selectedSegmentIndex = 0
        segmentContainer.addSubview(segmentedControl)
        segmentedControl.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        segmentedControl.edgesToSuperview()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView?.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        valueChanged(sender: segmentedControl)
        informationLabel.text = "next Cross"
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let fraction: CGFloat = 1.0 / CGFloat(dimension)
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(fraction),
            heightDimension: .fractionalWidth(fraction)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(fraction)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    @objc func valueChanged(sender: UISegmentedControl) {
          switch sender.selectedSegmentIndex {
          case 0:
              dimension = 3
              setUpGrid()
          case 1:
              dimension = 4
              setUpGrid()
          case 2:
              dimension = 6
              setUpGrid()
          default:
              print("error")
          }
      }
    
    private func setUpGrid() {
        viewModel.setUpModel {
            self.collectionView.collectionViewLayout = self.createLayout()
            self.collectionView.reloadData()
        }
    }
    
    private func  switchUser() {
        if currentUser == 0 {
            currentUser = 1
        } else {
            currentUser = 0
        }
    }
    
    private func showAlert(winner: String) {

        let alert = UIAlertController(title: "Game over", message: winner, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                self.valueChanged(sender: self.segmentedControl)
                self.currentUser = 0
            }
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func resetButtonPressed(_ sender: UIButton) {
        valueChanged(sender: segmentedControl)
        currentUser = 0
    }
}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  viewModel.model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell else {return UICollectionViewCell()}
        cell.configure(object:  viewModel.model[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else {return}
        guard let index = viewModel.model.firstIndex(where: { $0.column == cell.column && $0.row == cell.row}) else {return}
        // do not let update already pressed zones
        guard viewModel.model[index].isPressed == false else {return}
        viewModel.model[index].isPressed = true
        viewModel.model[index].userType = currentUser
        switchUser()
        collectionView.reloadData()
        
        //trigger the check via RXSwift instead
        //viewModel.checkWinner()
        checkMessage.onNext(())
    }
}

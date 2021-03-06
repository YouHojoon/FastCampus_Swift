//
//  TodoListViewController.swift
//  TodoList
//
//  Created by joonwon lee on 2020/03/19.
//  Copyright © 2020 com.joonwon. All rights reserved.
//

import UIKit

class TodoListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var inputViewBottom: NSLayoutConstraint!
    @IBOutlet weak var inputTextField: UITextField!
    
    @IBOutlet weak var isTodayButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    
    // TODO: TodoViewModel 만들기
    let todoListViewModel = TodoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: 키보드 디텍션
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // TODO: 데이터 불러오기
        self.todoListViewModel.loadTasks()
    }
    
    
  
    @IBAction func isTodayButtonTapped(_ sender: Any) {
        // TODO: 투데이 버튼 토글 작업
        self.isTodayButton.isSelected = !self.isTodayButton.isSelected
    }
    
    
    
    
    @IBAction func addTaskButtonTapped(_ sender: Any) {
        // TODO: Todo 태스크 추가
        // add task to view model
        // and tableview reload or update
    
        guard let detail = self.inputTextField.text, detail.isEmpty == false else {
            return
        }
        
        let todo = TodoManager.shared.createTodo(detail: detail, isToday: self.isTodayButton.isSelected)
        
        self.todoListViewModel.addTodo(todo)
        self.collectionView.reloadData()
        self.inputTextField.text = ""
        self.isTodayButton.isSelected = false
    }
    
    // TODO: BG 탭했을때, 키보드 내려오게 하기
    @IBAction func tapBG(_ sender: Any) {
        self.inputTextField.resignFirstResponder()
    }
    
}
    extension TodoListViewController {
        @objc private func adjustInputView(noti: Notification) {
            guard let userInfo = noti.userInfo else { return }
            // TODO: 키보드 높이에 따른 인풋뷰 위치 변경
            
            guard let keyboardFrmae = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return} //키보드가 다 올라왔을 때 높이 받기
            if noti.name == UIResponder.keyboardWillShowNotification{
                let adjustmentHeight = keyboardFrmae.height - self.view.safeAreaInsets.bottom
                
                self.inputViewBottom.constant = adjustmentHeight
            }else{
                self.inputViewBottom.constant = 0
            }
            
        }
    }
    
    extension TodoListViewController: UICollectionViewDataSource {
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            // TODO: 섹션 몇개
            return todoListViewModel.numOfSection
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            // TODO: 섹션별 아이템 몇개
            if section == 0 {
                return todoListViewModel.todayTodos.count
            }
            else{
                return todoListViewModel.upcompingTodos.count
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            // TODO: 커스텀 셀
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodoListCell", for: indexPath) as? TodoListCell else {
                return UICollectionViewCell()
            }
            
            // TODO: todo 를 이용해서 updateUI
            var todo: Todo
            
            if indexPath.section == 0{
                todo = todoListViewModel.todayTodos[indexPath.item]
            }
            else{
                todo = todoListViewModel.upcompingTodos[indexPath.item]
            }
            
            cell.updateUI(todo: todo)
            // TODO: doneButtonHandler 작성
            cell.doneButtonTapHandler = {isDone in
                todo.isDone = isDone
                self.todoListViewModel.updateTodo(todo)
                self.collectionView.reloadData()
            }
            // TODO: deleteButtonHandler 작성
            cell.deleteButtonTapHandler = {
                self.todoListViewModel.deleteTodo(todo)
                self.collectionView.reloadData()
            }
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TodoListHeaderView", for: indexPath) as? TodoListHeaderView else {
                    return UICollectionReusableView()
                }
                
                guard let section = TodoViewModel.Section(rawValue: indexPath.section) else {
                    return UICollectionReusableView()
                }
                
                header.sectionTitleLabel.text = section.title
                return header
            default:
                return UICollectionReusableView()
            }
        }
    }
    
    extension TodoListViewController: UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            // TODO: 사이즈 계산하기
            
            let width = collectionView.bounds.width
            let hegith: CGFloat = 50
            return CGSize(width: width, height: hegith)
        }
    }
    
    class TodoListCell: UICollectionViewCell {
        
        @IBOutlet weak var checkButton: UIButton!
        @IBOutlet weak var descriptionLabel: UILabel!
        @IBOutlet weak var deleteButton: UIButton!
        @IBOutlet weak var strikeThroughView: UIView!
        
        @IBOutlet weak var strikeThroughWidth: NSLayoutConstraint!
        
        var doneButtonTapHandler: ((Bool) -> Void)?
        var deleteButtonTapHandler: (() -> Void)?
        
        override func awakeFromNib() {
            super.awakeFromNib()
            reset()
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            reset()
        }
        
        func updateUI(todo: Todo) {
            // TODO: 셀 업데이트 하기
            checkButton.isSelected = todo.isDone
            descriptionLabel.text = todo.detail
            descriptionLabel.alpha = todo.isDone ? 0.2 : 1
            deleteButton.isHidden = todo.isDone == false
            showStrikeThrough(todo.isDone)
        }
        
        private func showStrikeThrough(_ show: Bool) {
            if show {
                strikeThroughWidth.constant = descriptionLabel.bounds.width
            } else {
                strikeThroughWidth.constant = 0
            }
        }
        
        func reset() {
            // TODO: reset로직 구현
            self.descriptionLabel.alpha = 1
            self.deleteButton.isHidden = true
            showStrikeThrough(false)
        }
        
        @IBAction func checkButtonTapped(_ sender: Any) {
            // TODO: checkButton 처리
            let isDone = self.checkButton.isSelected
            self.checkButton.isSelected = !self.checkButton.isSelected
            self.doneButtonTapHandler?(self.checkButton.isSelected)
            self.descriptionLabel.alpha = isDone ? 1 : 0
            self.deleteButton.isHidden = !isDone
        }
        
        @IBAction func deleteButtonTapped(_ sender: Any) {
            // TODO: deleteButton 처리
            deleteButtonTapHandler?()
        }
    }
    
    class TodoListHeaderView: UICollectionReusableView {
        
        @IBOutlet weak var sectionTitleLabel: UILabel!
        
        override func awakeFromNib() {
            super.awakeFromNib()
        }
    }


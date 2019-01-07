//
//  ViewController.swift
//  Tastmanager
//
//  Created by Kirill Verhoturov on 19/11/2018.
//  Copyright © 2018 Kirill Verhoturov. All rights reserved.
//

import UIKit
import RealmSwift

class TasksList: Object {
    @objc dynamic var task = ""
    @objc dynamic var completed = false
}

class ViewController: UITableViewController {
    
    let realm = try! Realm() // Доступ к хранилищу
    var items: Results<TasksList>! //Контейнер со свойствами объекта TaskList
    
    var cellId = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()

        items = realm.objects(TasksList.self)
    }
    
    
    func setupView(){
        view.backgroundColor = .white
        
        navigationController?.navigationBar.topItem?.title = "Tast Manager"
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 78/255,
                                                                   green: 45/255,
                                                                   blue: 121/255,
                                                                   alpha: 1)
        
        
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addItem))
        navigationItem.rightBarButtonItem = button
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    // Действие при нажатии на кнопку "Добавить"
    @objc func addItem(_ sender: AnyObject) {
        addAlertForNewItem()
    }
    
    func addAlertForNewItem() {
        
        let alert = UIAlertController(title: "Новая задача", message: "Пожалуйста заполните поле", preferredStyle: .alert)
        
        var alertTextField: UITextField!
        alert.addTextField { textField in
            alertTextField = textField
            textField.placeholder = "Новая задача"
        }

        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { action in
            guard let text = alertTextField.text , !text.isEmpty else { return }
            
            let task = TasksList()
            task.task = text
            
            try! self.realm.write {
                self.realm.add(task)
            }
            
            self.tableView.insertRows(at: [IndexPath.init(row: self.items.count-1, section: 0)], with: .automatic)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .destructive, handler: nil)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Table View DataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count != 0 {
            return items.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.task
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editingRow = items[indexPath.row]
                
        let deleteAction = UITableViewRowAction(style: .default, title: "Удалить") { _,_ in
            try! self.realm.write {
                self.realm.delete(editingRow)
                tableView.reloadData()
            }
            
        }
        
        return [deleteAction]
    }
}


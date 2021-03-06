//
//  EditView.swift
//  StockTracker
//
//  Created by Chenning Li on 11/30/20.
//  Copyright © 2020 Chenning Li. All rights reserved.
//

import UIKit
import SwiftUI

//MARK: - EditView (UIViewControllerRepresentable)
struct EditView: UIViewControllerRepresentable {
    
    //@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var mainViewController: MainViewController
    
    func makeUIViewController(context: Context) -> EditTableViewController {
        return EditTableViewController(mainViewController: _mainViewController)
    }
    
    func updateUIViewController(_ contentViewController: EditTableViewController, context: Context) {}
    
}

class EditTableViewController: UIViewController {
    
    @ObservedObject var mainViewController: MainViewController
    var symbolLists: [SymbolList]
    var symbolForDeleting: [String] = []
    var editListsEnabled: Bool = false {
        didSet {
            addNewListButton.isHidden = !editListsEnabled
        }
    }
    
    //MARK: - INIT
    init(mainViewController: ObservedObject<MainViewController>) {
        _mainViewController = mainViewController
        self.symbolLists = mainViewController.wrappedValue.symbolLists
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 100, right: 0)
        
        tableView.isEditing = true
        
        //tableView.contentInset.bottom += 40
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    lazy var cancelButton: UIButton = {
        var button = UIButton()
        button.setTitle("Cancel", for: UIControl.State.normal)
        button.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancel), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    @objc func cancel() {
        self.dismiss(animated: true) {}
    }
    
    lazy var saveButton: UIButton = {
        var button = UIButton()
        button.setTitle("Save", for: UIControl.State.normal)
        button.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(save), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    
    //MARK: - save new symbols list (delete old viewModels, deleting files from disc storage, dismiss self)
    @objc func save() {
        
        if symbolLists != mainViewController.symbolLists {
            mainViewController.symbolLists = symbolLists
        }
        
        // deleting view models
        for symbol in symbolForDeleting {
            for index in 0..<mainViewController.chartViewControllers.count {
                if mainViewController.chartViewControllers[index].symbol == symbol {
                    mainViewController.chartViewControllers[index].mode = .remove
                    mainViewController.chartViewControllers.remove(at: index)
                    break
                }
            }
        }
        
        // deleting files from disc storage
        let files = StorageWrapper.getSymbolsFiles()
        
        for file in files {
            
            var deleteFile = true
            
            for list in mainViewController.symbolLists {
                for symbol in list.symbolsArray {
                    if file == symbol + "_STATISTICS" {
                        deleteFile = false
                        break
                    }
                }
            }
            
            if deleteFile {
                do {
                    try StorageWrapper.removeFile(name: file)
                } catch {
                    switch error {
                    case let error as StorageError:
                        debugPrint(error.errorDescription!)
                    default:
                        debugPrint(error.localizedDescription)
                    }
                }
                
            }
            
        }
        
        // changing view model's modes
        self.mainViewController.symbolLists.forEach { list in
            list.symbolsArray.forEach { symbol in
                
                if list.isActive {
                    self.mainViewController.modelWithId(symbol).mode = self.mainViewController.connectionCheck ? .active : .waiting
                } else {
                    self.mainViewController.modelWithId(symbol).mode = .hidden
                }
            }
        }
        
        // dismissing self
        self.dismiss(animated: true) {}
        
    }
    
    
    lazy var editListsButton: UIButton = {
        var button = UIButton()
//        button.layer.borderColor = UIColor.black.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.setTitle("Edit Lists", for: UIControl.State.normal)
        button.setImage(UIImage(systemName: "pencil"), for: UIControl.State.normal)
        button.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(editLists), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    @objc func editLists() {
        
        if editListsEnabled {
            editListsButton.setTitle("Edit Lists", for: UIControl.State.normal)
            editListsEnabled = false
            tableView.reloadData()
        } else {
            editListsButton.setTitle("Edit Symbols", for: UIControl.State.normal)
            editListsEnabled = true
            tableView.reloadData()
        }
    }
    
    lazy var addNewListButton: UIButton = {
        var button = UIButton(type: UIButton.ButtonType.custom)
        button.layer.borderColor = UIColor.black.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.setImage(UIImage(systemName: "plus"), for: UIControl.State.normal)
        button.setTitle(" Add New List", for: UIControl.State.normal)
        button.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addNewList), for: UIControl.Event.touchUpInside)
        button.isHidden = true
        return button
    }()
    
    @objc func addNewList() {
        
        let list = SymbolList(name: "LIST", symbolsArray: [])
        self.symbolLists.insert(list, at: 0)
        tableView.reloadData()
    }
    
    //MARK: - VIEW LIFECICLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "Header")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            tableView.heightAnchor.constraint(equalTo: view.heightAnchor, constant: 0)])
        
        view.addSubview(cancelButton)
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15)])
        
        view.addSubview(saveButton)
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)])
        
        view.addSubview(editListsButton)
        NSLayoutConstraint.activate([
            editListsButton.topAnchor.constraint(equalTo: saveButton.topAnchor, constant: 50),
            editListsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)])
        
        view.addSubview(addNewListButton)
        NSLayoutConstraint.activate([
            addNewListButton.topAnchor.constraint(equalTo: saveButton.topAnchor, constant: 50),
            addNewListButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15)])
    }
    
    enum KeyboardState {
        case unknown, entering, exiting
    }
    
    func keyboardState(for userInfo: [AnyHashable: Any], in view: UIView?) -> (KeyboardState, CGRect?) {
        var rold = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        var rnew = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        var keyboardState : KeyboardState = .unknown
        var newRect : CGRect? = nil
        if let view = view {
            let coordinateSpace = UIScreen.main.coordinateSpace
            rold = coordinateSpace.convert(rold, to: view)
            rnew = coordinateSpace.convert(rnew, to: view)
            newRect = rnew
            if !rold.intersects(view.bounds) && rnew.intersects(view.bounds) {
                keyboardState = .entering
            }
            if rold.intersects(view.bounds) && !rnew.intersects(view.bounds) {
                keyboardState = .exiting
            }
        }
        return (keyboardState, newRect)
    }
    
    var oldContentInset: UIEdgeInsets = UIEdgeInsets.zero
    var oldIndicatorInset: UIEdgeInsets = UIEdgeInsets.zero
    var oldOffset: CGPoint = .zero
    
    @objc func keyboardShow(_ notification: Notification) {
        //debugPrint("keyboardShow")
        let d = notification.userInfo!
        let (state, rnew) = keyboardState(for: d, in: self.view)
        //debugPrint(state)
        
        if state == .entering {
            //debugPrint(state)
            self.oldOffset = self.tableView.contentOffset
            self.oldContentInset = self.tableView.contentInset
            self.oldIndicatorInset = self.tableView.verticalScrollIndicatorInsets
        }
        if let rnew = rnew {
            let h = rnew.intersection(self.tableView.bounds).height
            self.tableView.contentInset.bottom = h + 100
            self.tableView.verticalScrollIndicatorInsets.bottom = h + 100
        }
    }
    
    @objc func keyboardHide(_ notification: Notification) {
        //debugPrint("keyboardHide")
        
        let d = notification.userInfo!
        let (state, _) = keyboardState(for: d, in: self.view)
        //debugPrint(state)
        
        if state == .exiting {
            //debugPrint(state)
            self.tableView.contentOffset = self.oldOffset
            self.tableView.verticalScrollIndicatorInsets = self.oldIndicatorInset
            self.tableView.contentInset = self.oldContentInset
        }
    }
}

//MARK: - UITEXTFIELDDELEGATE
extension EditTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {return true}
        symbolLists[textField.tag - 1].name = text
        textField.resignFirstResponder()
        return true
    }
    
}

//MARK: - UITableViewDelegate
extension EditTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if !editListsEnabled {
            let element = symbolLists[sourceIndexPath.section].symbolsArray[sourceIndexPath.row]
            self.symbolLists[sourceIndexPath.section].symbolsArray.remove(at: sourceIndexPath.row)
            self.symbolLists[destinationIndexPath.section].symbolsArray.insert(element, at: destinationIndexPath.row)
        } else {
            let element = symbolLists[sourceIndexPath.row]
            self.symbolLists.remove(at: sourceIndexPath.row)
            self.symbolLists.insert(element, at: destinationIndexPath.row)
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if !editListsEnabled {
            switch editingStyle {
            case .delete:
                tableView.performBatchUpdates({
                    self.symbolForDeleting.append(symbolLists[indexPath.section].symbolsArray[indexPath.row])
                    symbolLists[indexPath.section].symbolsArray.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                })
            case .insert:
                break
            default: break
            }
        } else {
            switch editingStyle {
            case .delete:
                tableView.performBatchUpdates({
                    for symbol in symbolLists[indexPath.row].symbolsArray {
                        self.symbolForDeleting.append(symbol)
                    }
                    symbolLists.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                })
            case .insert:
                break
            default: break
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if editListsEnabled {
            return 50
        } else {
            return 40
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UITableViewHeaderFooterView(reuseIdentifier: "Header")
        
        if !editListsEnabled {
            
            let label = UILabel()
            label.text = self.symbolLists[section].name
            label.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(label)
            
            NSLayoutConstraint.activate([
                
                label.topAnchor.constraint(equalTo: headerView.contentView.topAnchor, constant: 0),
                label.leadingAnchor.constraint(equalTo: headerView.contentView.leadingAnchor, constant: 15),
                label.trailingAnchor.constraint(equalTo: headerView.contentView.trailingAnchor, constant: -15),
                label.heightAnchor.constraint(equalToConstant: 30),
                
            ])
            
        }
        return headerView
    }
    
}


//MARK: - UITableViewDataSource
extension EditTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return editListsEnabled ? 1 : symbolLists.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return editListsEnabled ? symbolLists.count : symbolLists[section].symbolsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
        
        if editListsEnabled {
            
            // text field
            let textfield = UITextField()
            textfield.borderStyle = .roundedRect
            textfield.textAlignment = .justified
            textfield.layer.cornerRadius = 15
            textfield.backgroundColor = .clear
            textfield.clearButtonMode = .whileEditing
            textfield.layer.cornerRadius = 10
            textfield.contentMode = .center
            textfield.tag = indexPath.row + 1
            textfield.translatesAutoresizingMaskIntoConstraints = false
            textfield.delegate = self
            textfield.text = self.symbolLists[indexPath.row].name
            
            cell.contentView.addSubview(textfield)
            textfield.borderStyle = .roundedRect
            textfield.returnKeyType = .done
            textfield.enablesReturnKeyAutomatically = true
            textfield.autocorrectionType = .no
            
            NSLayoutConstraint.activate([
                //textfield.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 0),
                textfield.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
                textfield.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 15),
                textfield.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15),
                textfield.heightAnchor.constraint(equalToConstant: 40),
            ])
            
        } else {
            cell.textLabel?.text = symbolLists[indexPath.section].symbolsArray[indexPath.row]
        }
        return cell
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(mainViewController: MainViewController(from: "AAPL"))
    }
}

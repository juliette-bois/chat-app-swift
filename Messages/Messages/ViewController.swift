//
//  ViewController.swift
//  Messages
//
//  Created by Juliette Bois on 03.02.21.
//

import UIKit
import Starscream

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var myTable: UITableView!
    
    @IBOutlet weak var newRoom: UIBarButtonItem!
    
    var cellList:[String] = []
    var currentUser: Sender!
    var otherUser: Sender!
    
    public let roomList = WebSocketClass(url: "ws://127.0.0.1:9081/roomList")
    public let roomCreation = WebSocketClass(url: "ws://127.0.0.1:9081/roomCreation")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeSenders()
        
        myTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        myTable.delegate = self
        myTable.dataSource = self
        newRoom.action = #selector(addNewRoom(sender:))
        newRoom.target = self
        
        // room list part
        roomList.establishConnection()
        // retrieve room list from text
        roomList.setReceiveTextMethod(receiveTextMethod: { [self] string in
            let values = string.components(separatedBy: "|")
            if (values[0] != "") {
                cellList = values
                print(cellList)
                myTable.reloadData()
            }
        })
        
        // room creation part
        roomCreation.establishConnection()
        roomCreation.setReceiveTextMethod(receiveTextMethod: { [self] string in
            let tab = string.components(separatedBy: "|")
            let response = tab[1]
            if response == "OK" {
                cellList.append(tab[2])
                myTable.reloadData()
//                 TODO rediriger vers la room
            }
        })
    }
    
    func initializeSenders() {
        let alertController = UIAlertController(title: "Initialisation", message:"Indiquez votre nom et celui de votre interlocuteur", preferredStyle: UIAlertController.Style.alert);
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Votre nom"
        })
        
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Nom de l'interlocuteur"
        })
        
        let actionAdd = UIAlertAction(title: "Valider", style: UIAlertAction.Style.default, handler: {[self] action in
            let current = ((alertController.textFields![0]) as UITextField).text ?? ""
            let other = ((alertController.textFields![1]) as UITextField).text ?? ""
            
            if (current.count > 0 && other.count > 0) {
                self.currentUser = Sender(senderId: "self", displayName: current)
                self.otherUser = Sender(senderId: "other", displayName: other)
            }
        })
        
        alertController.addAction(actionAdd)
        self.present(alertController, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = cellList[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Show chat messages
        let vc  = ChatViewController()
        vc.title = cellList[indexPath.row]
        vc.currentUser = self.currentUser
        vc.otherUser = self.otherUser
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func addNewRoom(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Room Creation", message:"Entrer le nom de votre room", preferredStyle: UIAlertController.Style.alert);
        alertController.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Room Name"
        })
        
        let actionCancel = UIAlertAction(title: "Annuler", style: UIAlertAction.Style.cancel, handler: nil)
        
        let actionAdd = UIAlertAction(title: "Ajouter", style: UIAlertAction.Style.default, handler: {[self] action in
            let roomName = ((alertController.textFields!.first ?? UITextField()) as UITextField).text ?? ""
            if (roomName.count > 0) {
                self.roomCreation.write(text: "Creation|\(roomName)")
            }
        })
        
        alertController.addAction(actionCancel)
        alertController.addAction(actionAdd)
        self.present(alertController, animated: true, completion: nil)
    }

}


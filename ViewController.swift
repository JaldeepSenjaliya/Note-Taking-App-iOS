//
//  ViewController.swift
//  Notes_Application_Project
//
//  Created by user175465 on 6/23/20.
//  Copyright © 2020 user175465. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    var noteSavedArray = NSMutableArray()
    var noteSearchedArray = NSMutableArray()
    var searcgingNote = false
    
    @IBOutlet weak var searchNote: UISearchBar!
    @IBOutlet weak var nTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchNote.delegate = self
        searchNote.showsCancelButton = true
        searchNote.showsSearchResultsButton = true
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        let ndefaults = UserDefaults.standard
        if ndefaults.value(forKey: "noteSavedArray") != nil {
            let dataSaved = ndefaults.value(forKey: "noteSavedArray") as! NSArray
            noteSavedArray = dataSaved.mutableCopy() as! NSMutableArray
            print(noteSavedArray)
            searcgingNote = false
            nTableView.reloadData()
        }
       
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searcgingNote{
            return noteSearchedArray.count
        }else{
            return noteSavedArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 146
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note_TableView_Cell", for: indexPath) as! note_TableViewCell
        cell.selectionStyle = .none
        var cellDict = NSDictionary()
        if searcgingNote {
            cellDict = noteSearchedArray.object(at: indexPath.row) as! NSDictionary
        } else{
            cellDict = noteSavedArray.object(at: indexPath.row) as! NSDictionary
        }
        
        cell.name.text = cellDict["title"] as? String
        //cell.noteDescription.text = cellDict["note_description"] as? String
        
        let note_time = cellDict["time"] as? Int
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(note_time!)) as Date)
        cell.date.text = dateString

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var cellDict = NSDictionary()
        if searcgingNote//(searchNote != nil)
        {
            cellDict = noteSearchedArray.object(at: indexPath.row) as! NSDictionary
        } else {
            cellDict = noteSavedArray.object(at: indexPath.row) as! NSDictionary
        }
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "NoteDetailViewController") as! note_detailViewController
        newViewController.noteData = cellDict
        self.navigationController?.pushViewController(newViewController, animated: true)
    }

    @IBAction func add_btn_pressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "addNote", sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
     let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
       // Perform your action here
       self.noteSavedArray.removeObject(at: indexPath.row)
       print(self.noteSavedArray)
       let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "noteSavedArray") // keychanged
        
       defaults.setValue(self.noteSavedArray, forKey: "noteSavedArray") // here also
        
        defaults.synchronize()
       self.nTableView.reloadData()
       
         completion(true)
     }
    
    let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
      // Perform your action here
      var dicCell = NSDictionary()
      if self.searcgingNote {
          dicCell = self.noteSearchedArray.object(at: indexPath.row) as! NSDictionary
      } else {
          dicCell = self.noteSavedArray.object(at: indexPath.row) as! NSDictionary
      }
      let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
      let newViewController = storyBoard.instantiateViewController(withIdentifier: "edit_noteviewcontroller") as! edit_noteViewController
      newViewController.dicNote = dicCell
      newViewController.noteSavedArray = self.noteSavedArray
      self.navigationController?.pushViewController(newViewController, animated: true)
      
      completion(true)
    }
    
        deleteAction.backgroundColor = UIColor.red
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            searcgingNote = true
            for index in 0..<noteSavedArray.count {
                let dicIndex = noteSavedArray.object(at: index) as? NSDictionary
                let strTitle = dicIndex!["title"] as! String
                let strSearch = searchBar.text!
                if strTitle.lowercased().contains(strSearch.lowercased()) {
                    noteSearchedArray.add(dicIndex!)
                }
            }
            nTableView.reloadData()
            searchBar.resignFirstResponder()
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searcgingNote = false
        searchBar.text = ""
        nTableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
}


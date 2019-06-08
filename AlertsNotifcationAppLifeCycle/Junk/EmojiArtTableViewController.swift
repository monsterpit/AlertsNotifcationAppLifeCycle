//
//  EmojiArtTableViewController.swift
//  EmojiArtDragnDropCollectionnTable
//
//  Created by Boppo on 03/05/19.
//  Copyright © 2019 MB. All rights reserved.
//

import UIKit

class EmojiArtTableViewController: UITableViewController {
    // So as with any MVC we should think abou it's model
    // and here the model is emojiArtDocument i.e. list of emoji art documents
    //As our app progresses we gonna allow new documents to be added
    //this model doesnt have enough stuff in it for sections but you could imagine it would
    // what if we had recently created documents ,recently deleted , other kinds of sections
    
    var emojiArtDocuments = ["One","Two","Three"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       // return 0
        return emojiArtDocuments.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = emojiArtDocuments[indexPath.row]
        
        
        return cell
    }


    
    @IBAction func newEmojiArt(_ sender: UIBarButtonItem) {
        
        // This madeUnique is in Utilities.swift
        emojiArtDocuments += ["Untitled".madeUnique(withRespectTo: emojiArtDocuments)]
        
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryOverlay{
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
    
    
    
    /*
    // Override to support conditional editing of the table view.
     //This say where you are allowed to delete this row and now the default is yes
     // So you dont actually need to implement below method if you allow all rows to be deleted
     // this is only way to prevent deletion from happening here
     //So we gonna allow all of our rows to be deleted here so we wont uncomment this implement method
     
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    /*
     but why aint delete still working because you also have to implement below method
     commit editingStyle either delete or insert you have to commit that , that means you have to commit it to your model
     So it is really easy to do it has
     if .delete or if .insert
     this insert is kind of a UITableView for adding we dont need that because we have a plus button
     
 */
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            emojiArtDocuments.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            
            /*            emojiArtDocuments.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
             both has to be in perfect sync
             If dont have this perfectly sync you will get a crash  when this happens and it will say something like number of rows in the table did not match when i went to update the rows
             //in other words it's saying your model and table is out of sync or dont match up
             So it is easy to get it out of sync
             
             //this is using tableView.deleteRows instead of reload table
 */
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}




/*
 When we add buttons to top areas of a navigation controller
 we dont add regular buttons
 It will let you do it but dont do it
 
 You put barButton
 because its in a little navigation bar at the top  that's the button you want
 you get all kind of messed up if you use the wrong button there
 
 there are some predefined buttons up there like a camera , like save  , and there also a add
 And I strongly recommend using one of these predefined one's if it describes what you are doing because user will be used to that icon or that image doing what you expect right there
 
 Normal this just a normal bar button and we can just ctrl drag to it to create an outlet
 */



/*
 Currently we where unable to swipe tableview i.e. master of splitView away
That's because this app thinks we are in landscape mode on an iPad
 of course this master and detail are side by side but since we are in multitasking mode so much of our screen is taken up with safari over on right that's its annoying because we really want to focus on EmojiArtDocument
 So lets make it so that the splitView on the left can be slid out of the way even in the splitView in landscape mode
 
 It's quite easily though splitView has a var property called "prefered display mode"
 and you can control what happens with the master through that and it's just that the defualt here is not what we want
 
 So we gonna set this thing in our master
 And we will set it in viewWillLayoutSubviews
 Wow that seems weird place to set there
 the reason i am gonna set there is because when the layout changes of a splitView it often  resets the prefered mode
 So I am gonna keep enforcing master being slide on top mode I am have to keep telling it to do that
 But i am also have to careful because setting that prefered mode can cause it to relay out, So i dont want to end up in an infinite loop here
 where in layoutSubviews preferred mode it's causing layout i am coming back in
 if splitViewController?.preferredDisplayMode != .primaryOverlay{
 splitViewController?.preferredDisplayMode = .primaryOverlay
 }
 
 primaryOverlay will keep it enforcing everytime even everytime we rotate or i am keep forcing it because I always want this tableView to be appearing on top of my EmojiArtView but I also want it to swipe it out of my way 
 */

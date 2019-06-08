//
//  DocumentBrowserViewController.swift
//  EmojiArtPersistantDataP2UIDocument
//
//  Created by Boppo Technologies on 04/06/19.
//  Copyright © 2019 Boppo Technologies. All rights reserved.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    //viewdidLoad is where we gonna configure our document
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        allowsDocumentCreation = false
        
        // MARK: - Check for iPad
        
        //as we cant create new docs on iPhone as we cant drag from safari in iPhone
        //So limiting creation of new docs to iPad only
        
        // Checking For if device is iPad
        if UIDevice.current.userInterfaceIdiom == .pad{
            
            //Because we only know showing of 1 emojiArtDocument at a time
            //  allowsPickingMultipleItems = false
            
            // Update the style of the UIDocumentBrowserViewController
            // browserUserInterfaceStyle = .dark
            // view.tintColor = .white
            
            // Specify the allowed content types of your application via the Info.plist.
            
            
            
            /*
             This time not in document Directory
             I dnt want it on documents when the user looks there
             I am gonna put it in applicationSupportDirectory
             applicationSupportDirectory is a great place to put things that are kinda a behind the scenes, they are permanent , I want this template to stick around , I dont want it to cached and deleted
             Although I can put it in caches because I can always recreate it in viewDidLoad
             */
            template = try? FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                //create: true).appendingPathComponent("Untitled.json")
                create: true).appendingPathComponent("Untitled.emojiart")
            
            // CHANGE MADE
            // the above change to the name of our blank template
            // combined with the addition of an emojiart file type
            // in Exported UTIs in Project Settings for Target's Info tab
            // and changing the Document Type in that tab to edu.stanford.cs193p.emojiart
            // makes it so documents can now be opened in our app from the Files app!
            
            if template != nil {
                
                /*
                 createFile is a nice way to create a file because it doesnt throw or anything like that and it returns a boolean whether that file either got created or already exist
                 And  if it is true then I will allow document creation
                 Otherwise I wouldnt allow document creation because I couldnt create the template
                 Now this importHandler(template, .copy) passing in template and copy it in applicationDirectory
                 
                 Data() creates a blank document
                 */
                allowsDocumentCreation = FileManager.default.createFile(atPath: template!.path, contents: Data())
            }
            
            
            
        }
        

        
    }
    
    //make this template to point to some blank document
    var template : URL?
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    //Used for handling copy of template
    //Give me the url of document because someone whats to create one
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        
        importHandler(template, .copy)
    }
    
    
    /* not implementing below 3 funcs
     didPickDocumentsAt  when people click on document
     didImportDocumentAt  when some other app click Files app ask's you to open documents
     
     both are doing same presentDocument() which is please put up your ViewController to show it
     
     failedToImportDocumentAt called when you couldnt open document
     you should put up an alert here
     
     */
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    //This is just a internal method that is called from other things for presenting the MVC for the given URL
    func presentDocument(at documentURL: URL) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        /*
         The viewcontroller I wanna present is actually not EmojiArtViewController its the navigation controller its in
         So I have to somehow instiate navigation Controller which will also bring EmojiArtViewController in
         
         So we have to give NavigationController a identifier in Storyboard 
        */
        
        let documentVC = storyBoard.instantiateViewController(withIdentifier: "DocumentMVC")
        
        //.content is in utility extension for UIVC for checking naavigationController and returning VC
        if let emojiArtViewController = documentVC.contents as? EmojiArtViewController{
            
            //URL that we want to present
            emojiArtViewController.document = EmojiArtDocument(fileURL: documentURL)
            
        }
        
        
        //when someone clicked on it in file browser we want to slide up instead of just appear i.e. slide up from bottom
        //There is even a way to make it grow out of icon in file system (***)
        present(documentVC,animated: true)
        
        //But this documentMVC has a emojiArtViewController that we need to set document of
        //Then in target -> Info changing Document type from images to json
        
    }
}


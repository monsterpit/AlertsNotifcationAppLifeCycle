//
//  TextFieldCollectionViewCell.swift
//  EmojiArtPersistantDataP1
//
//  Created by MB on 5/22/19.
//  Copyright © 2019 MB. All rights reserved.
//

import UIKit

class TextFieldCollectionViewCell: UICollectionViewCell,UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!{
        didSet{
            //Assigning delegate and implementing its protocol
            textField.delegate = self
        }
    }
    
    
    //And when this happens i want to talk back to collectionView add the emoji that was in my textField
    //But how do I talk back to my collectionView
    //The collectionViewccEll doesnt really have a pointer their collectionView
    // So its a interesting problem ...!!! Lot of people will go find the collectionView and go talk to it
    //But there's actually a much simplier way to do it with closures
    
    //A closure a function that takes no arguments and returns no arguments thats an optional
    var resignationHandler : (()-> Void)?
    
    // This method is called after the text field resigns its first responder status
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //And when textFieldDidEndEditing we gonna call that closure
        resignationHandler?()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // relinquish its status as first responder in its window. means it stops using keyboard and keyboard disappears , if you dont this keyboard stays up
        textField.resignFirstResponder()
        //Now anyone that's interested when my textField resigns can just set this closure 
        return true
    }
}

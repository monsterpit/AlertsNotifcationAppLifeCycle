//
//  EmojiArtDocument.swift
//  EmojiArtPersistantDataP2UIDocument
//
//  Created by Boppo Technologies on 04/06/19.
//  Copyright © 2019 Boppo Technologies. All rights reserved.
//

import UIKit

class EmojiArtDocument: UIDocument {
    
    /* To do either of this we actually need a Model
     and anytime we save our model for our controller I will just take my controller model and put it in the document and then the document knows what to do from there
 */
    var emojiArt : EmojiArt?
    
    var thumbnail : UIImage?
    
    //data to a model
    //contents(forType typeName: String) throws -> Any return Any not data because this Any can be a file wrapper (a directory full of files) used a way to represent document just as a way data is .
    // but usually it is going to return data infact check default returns a blank Data()
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
       // return Data()
        
        //Data() which means a blank document
        return emojiArt?.json ?? Data()
    }
    
    /*
    ofType typeName: String?
     which is of type UTI like public.json is UTI or edu.standford.cs193p.art could be a UTI
     i.e. it is a unique identifier of that type
     
     Now we dont really care because we only open one thing o anything we open JSON or emojiArt or whatever is all just a JSON data anyways to us so we dont care about the type
     
     But some apps might open multiple different types they might need to know what type it is in order to successfullt open it or save it
     and that's it this is all we need to do to do an emojiArtDocument we are done
     Now we can use all the API of UI document like asynchronous opening and saving , working over iCloud aautosaving , all that stuff just over for free as long as we implemented this things so lets use all those things back in EmojiArtViewController to replace the places where we  where accessing the file system directly
    */
    
    //model to a data
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        
        //Here we are data passed to us and we want to convert it to EmojiArt
        // contents as? Data because We dont deal with filewrapper that is Any
        if let json = contents as? Data {
            
            emojiArt = EmojiArt(json: json)
            
        }
        
    }
    
    
    //return dictionary of file attributes like is this file hidden
    override func fileAttributesToWrite(to url: URL, for saveOperation: UIDocument.SaveOperation) throws -> [AnyHashable : Any] {
        
        var attributes = try super.fileAttributesToWrite(to: url, for: saveOperation)
        
        if let thumbnail = self.thumbnail {
            
            attributes[URLResourceKey.thumbnailDictionaryKey] = [URLThumbnailDictionaryItem.NSThumbnail1024x1024SizeKey : thumbnail]
            
            //NSThumbnail1024x1024SizeKey any size if too small will use document icon again
            
        }
        
        return attributes
    }
}


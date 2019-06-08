//
//  EmojiArt.swift
//  EmojiArtPersistantDataP2
//
//  Created by Boppo Technologies on 03/06/19.
//  Copyright © 2019 MB. All rights reserved.
//

import Foundation

//Lets make it generate JSON
struct EmojiArt : Codable
{
    
    var url : URL
    
    var emojis = [EmojiInfo]()
    
    struct EmojiInfo : Codable {
        //position x and y and its text and size i.e. font Size
        // we have Int instead of CGFloat remember these is a Model so it can be anything so it can also be double
        //I decided to have Int because I want my JSON to look nice 
        let x : Int
        
        let y : Int
        
        let text : String
        
        let size : Int
        
    }
    
    
    // To get JSON version of EmojiArt
    var json : Data? {

        //     for pretty print
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//
//        return try? encoder.encode(self)
        
        return try? JSONEncoder().encode(self)
        
    }
    
    //Failable initializer that takes some json which is a data if I cant initialize it then I am going to fail and return nil
    //This is much likely to fail as you can imagine corrupted JSON just playing the wrong JSON file , empty JSON file all these things would call this to fail and its fine just this will not initialize this is only gonna initialize if this is going to be valid JSON about encoded something from above basically that's only way it will succeed 
    init?(json : Data){
        
        //I am trying to decode EmojiArt from json data
        if let newValue = try? JSONDecoder().decode(EmojiArt.self, from: json){
            
            //Now if I am able to decode it out of there now I have it the new thing and new value and so I am gonna say
            
            self = newValue
            
        }else{
            
            return nil
            
        }
        
    }
    
    

    init(url : URL , emojis : [EmojiInfo]) {
        
        self.url = url
        
        self.emojis = emojis
    
    }
    
}

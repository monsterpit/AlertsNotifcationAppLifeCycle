//
//  EmojiArtView.swift
//  EmojiArtDragAndDrop
//
//  Created by Boppo on 02/05/19.
//  Copyright © 2019 MB. All rights reserved.
//

import UIKit


// this is the delegate protocol for EmojiArtView
// EmojiArtView wants to be able to let people
// (usually its Controller)
// know when its contents have changed
// but MVC does not allow it to have a pointer to its Controller
// it must communicate "blind and structured"
// this is the "structure" for such communication
// see the delegate var in EmojiArtView below
// note that this protocol can only be implemented by a class
// (not a struct or enum)
// that's because the var with this type is going to be weak
// (to avoid memory cycles)
// and weak implies it's in the heap
// and that implies its a reference type (i.e. a class)

protocol EmojiArtViewDelegate : class {
    func emojiArtViewDidChange(_ sender : EmojiArtView)
}

extension Notification.Name{
    
    static let EmojiArtViewDidChange = Notification.Name("EmojiArtViewDidChange")
    
}

class EmojiArtView: UIView,UIDropInteractionDelegate {
    
    // MARK: - Delegation
    
    // if a Controller wants to find out when things change
    // in this EmojiArtView
    // the Controller has to sign up to be the EmojiArtView's delegate
    // then it can have methods in that protocol invoked on it
    // this delegate is notified every time something changes
    // (see uses of this delegate var below and in EmojiArtView+Gestures.swift)
    // this var is weak so that it does not create a memory cycle
    // (i.e. the Controller points to its View and its View points back)
    
    weak var delegate : EmojiArtViewDelegate?
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        addInteraction(UIDropInteraction(delegate: self))
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self) { (provider) in
            
            //Get drop location
            let dropPoint = session.location(in: self)
            
            //Get all NSattributedString
            for attributedString in provider as? [NSAttributedString] ?? [] {
                self.addLabel(with : attributedString, centeredAt : dropPoint)
                
                self.delegate?.emojiArtViewDidChange(self)
                
                //Notification.Name.EmojiArtViewDidChange btw swift can infer this
                NotificationCenter.default.post(name: .EmojiArtViewDidChange, object: self)
                
            }
            
        }
    }
    
    //putting things in this dictionary will put it in heap but only as long  as this emojiArt is  in the heap as soon as the emojiArtView leaves the heap label.observe will leave the heap and all the obervations will leave the heap
    //So that's  good with KVO not doing that remove obserVer thing like Notification because when thing leave the heap- naturally the observations naturally stops however what if we dont leave the heap and we remove that subView
    private var labelObservations = [UIView:NSKeyValueObservation]()
    
    //remember I am controller over there and controller can call anything it want in the view , view cant call anything in controller without blind structured communication but controller can call anything it want in it
    // so made it public from private
     func addLabel(with attributedString : NSAttributedString , centeredAt point : CGPoint){
        let label = UILabel()
        label.backgroundColor = .clear
        label.attributedText = attributedString
        label.sizeToFit()
        label.center = point
        addEmojiArtGestureRecognizers(to: label)
        addSubview(label)
        
        //remember observe returns a cookie
        labelObservations[label] = label.observe(\.center) { (label, change) in
            self.delegate?.emojiArtViewDidChange(self)
            
            //Notification.Name.EmojiArtViewDidChange btw swift can infer this
            NotificationCenter.default.post(name: .EmojiArtViewDidChange, object: self)
        }
        
       //whenever this view  gets removed from super view I have to let this observation leave the heap in other word we have to remove it from here
    }
    
    //called when ever a subview is removed from superView
    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        
        
        if labelObservations[subview] != nil {
            labelObservations[subview] = nil
            //setting the labelObservations[subview] to nil will force observe to leave the heap 
        }
    }
    
    var backgroundImage : UIImage? {
        didSet{
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }


}

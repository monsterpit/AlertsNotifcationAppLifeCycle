//
//  EmojiArtViewController.swift
//  EmojiArtDragAndDrop
//
//  Created by Boppo on 02/05/19.
//  Copyright © 2019 MB. All rights reserved.
//

import UIKit

/*
Some people say if you put an extension here EmojiArt.EmojiInfo you have just added UI to your model
 No this is my controller now the fact that my controller is implementing this as in part of extension
 This extension lives in my controller and thats perfectly legal to do
 And you will see iOS do that like something like NSAttributedString which is aactually in Foundation not a UI thing
 but when you start adding font and stuff like that now it start becoming UI Thing
 all that stuff is implemented in UIKit by extension NSAttributedString , they are doing the same thing over there
*/
/*
 So I decided to do it with intializer instead of adding new function
 It initializes it with label
 */
extension EmojiArt.EmojiInfo{
    
    //MARK:- Failable Initializer you return nil
    init?(label : UILabel){
        
        if let attributedText = label.attributedText , let font = attributedText.font{
            
            x = Int(label.center.x)
            
            y = Int(label.center.y)
            
            text = attributedText.string
            
            size = Int(font.pointSize)
            
        }else{
            
            return nil
            
        }
        
    }
    
}


class EmojiArtViewController: UIViewController,UIDropInteractionDelegate,UIScrollViewDelegate , UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout , UICollectionViewDragDelegate,UICollectionViewDropDelegate , EmojiArtViewDelegate{

    //MARK: - Model
    
    //We could have model just stored like this anh have some functions to look at all UILabel and grab the URL and build the emojiArt and return it
    //But we can make this a computed property , but why I am doing it
    /*
     Any time when someone wants my model I am gonna look through my UI and make it for them (get)
and any time someone sets my model I am gonna go update my UI to be like that way this things cant never be out of sync
     myModel be always be perfect match with my UI and that is a really good thing to have in a controller
     The model and UI are always in sync
 */
    
    /*
     Now we are in great shape now we have a model that we can set and get that makes our UI work and all we need to do is make it persistent , Make it store on the disk
     And we gonna make it persistent with having emojiArt thing over there become codable and turn itself into JSON and then we gonna use JSON as our file format 
 */
    var emojiArt : EmojiArt?{
        
        get{
            
            if let url = emojiArtBackImage.url{
                
                //flatMap if returns nil it ignores it
               // let emojis = emojiArtView.subviews.flatMap{$0 as? UILabel}
                
               // let emojis = emojiArtView.subviews.flatMap{$0 as? UILabel}.flatMap { EmojiArt.EmojiInfo(label: $0)}
                let emojis = emojiArtView.subviews.compactMap{$0 as? UILabel}.compactMap { EmojiArt.EmojiInfo(label: $0)}
                
                /* Now we have emojiLabels
                 Now we have to turn it into array of EmojiInfo
                 We gonna do that by writing an extension to struct EmojiInfo
                 Im gonna put that extension in over my controller because that extension is gonna take UILabel as an argument and return an emojiInfo as the value that UILabel is a UI thing so that cannot be in my model but it can be in my controller
                 */
                
                return EmojiArt(url: url, emojis: emojis)
                
            }
            
                return nil
            
        }
        set{
            
            //Setting emojiArtBackImage to nil
            emojiArtBackImage = (nil,nil)
            
            //removing all labels from emojiArtView
            emojiArtView.subviews.compactMap { $0 as? UILabel   }.forEach { $0.removeFromSuperview()  }
            
            if let url = newValue?.url {
                
                imageFetcher = ImageFetcher(fetch: url, handler: { (url, image) in
                    
                    DispatchQueue.main.async {
                        
                        self.emojiArtBackImage = (url,image)
                        
                        
                        
                        newValue?.emojis.forEach{
                            
                            let attributedText = $0.text.attributedString(withTextStyle: .body, ofSize: CGFloat($0.size))
                            
                            self.emojiArtView.addLabel(with: attributedText, centeredAt:  CGPoint(x: $0.x, y: $0.y))
                        }
                        
                    }
                    
                })
                
            }
            
        }
        
    }
    
    //what's inside emojiArt document there's URL in the background and then there are all those emoji what they are where they are and how big they are that's what emojiArt document looks like 
    
    //This is going to be set in that code from the file chooser when the file chooser chooses the file we are gonna set our document in our new MVC and then its just gonna magicalaly show its stuff using all the document API
    
      // MARK: - Document Handling
    
    var document : EmojiArtDocument?
    // we no longer need a save method or button
    // because now we are the EmojiArtView's delegate
    // (search for "delegate = self" below)
    // and we get notified when the EmojiArtView changes
    // (we also note when a new image is dropped, search "documentChanged" below)
    // and so we can just update our UIDocument's Model to match ours
    // and tell our UIDocument that it has changed
    // and it will autosave at the next opportune moment
    
    //  @IBAction func save(_ sender: UIBarButtonItem? = nil) {
    func documentChanged() {
        // NO CHANGES *INSIDE* THIS METHOD WERE MADE AFTER LECTURE 14
        // JUST ITS NAME WAS CHANGED (FROM save TO documentChanged)
        
        // update the document's Model to match ours
        document?.emojiArt = emojiArt
        // then tell the document that something has changed
        // so it will autosave at next best opportunity
        if document?.emojiArt != nil {
            document?.updateChangeCount(.done)
        }
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        
        // the call to save() that used to be here has been removed
        // because we no longer explicitly save our document
        // we just mark that it has been changed
        // and since we are reliably doing that now
        // we don't need to try to save it when we close it
        // UIDocument will automatically autosave when we close()
        // if it has any unsaved changes
        // the rest of this method is unchanged from previous
       // save()
        
        //utility
        if document?.emojiArt != nil{
        document?.thumbnail = emojiArtView.snapshot
        }
        
        
        dismiss(animated: true){
            //document?.close(completionHandler: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
            /*
             It does have a completionHandler but I dont really care because I am not gonna do anything whether it's successful or not , I am just gonna try to close it and hope it will be and 99% of time its going to be , I could catch errors and some of problems for some reasons closing and having problems but the best we can do is just try to close and see what happens
             
             */
            
            self.document?.close()
            
        }
        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
       //  When our view first appears we need to open our document so
        document?.open(completionHandler: { (success) in
            
            if success {
                
                //This localizedName just comes from URL its just the last part of URL without the file extension put in there
                self.title = self.document?.localizedName
                
                self.emojiArt = self.document?.emojiArt
                
            }
        })

    }
    
    
//    // To test our app We are going to set my document to be untitled.json eventually it would be chooser thing
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//
//        if let url = try? FileManager.default.url(
//            for: .documentDirectory,
//            in: .userDomainMask,
//            appropriateFor: nil,
//            create: true).appendingPathComponent("Untitled.json"){
//
//            //remember that UIDocument only has 1 initializer that is url
//            document = EmojiArtDocument(fileURL: url)
//        }
//    }
    @IBOutlet weak var dropZone: UIView! {
        didSet{
            dropZone.addInteraction(UIDropInteraction(delegate: self))
            
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(emojiArtView)
        }
    }
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    
    // when we create our EmojiArtView, we also set ourself as its delegate
    // so that we can get emojiArtViewDidChange messages sent to us
    lazy var emojiArtView : EmojiArtView = {
        let eav = EmojiArtView()
        eav.delegate = self
        return eav
    }()
    
    func emojiArtViewDidChange(_ sender: EmojiArtView) {
        documentChanged()
    }
    
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewWidth.constant = scrollView.contentSize.width
        
        scrollViewHeight.constant = scrollView.contentSize.height
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiArtView
    }
    
    //For storing ImageURL
    // And I am not gonna set it from here I am always gonna set it from emojiArtBackImage but just gonna use it as storage
    // some people might put _ in front of this  like _emojiArtBackgroundImageURL
    // To emphasize this is background storage we are not ever gonna set this directly we gonna set the URL in emojiArtBackImage
    private var _emojiArtBackgroundImageURL : URL?
    
    var emojiArtBackImage : (url : URL?,image : UIImage?){
        get{
            return (_emojiArtBackgroundImageURL,emojiArtView.backgroundImage)
        }
        set{
            _emojiArtBackgroundImageURL = newValue.url
            scrollView?.zoomScale = 1.0
            emojiArtView.backgroundImage = newValue.image
            let size = newValue.image?.size ?? CGSize.zero
            emojiArtView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView?.contentSize = size
            
            scrollViewWidth?.constant = size.width
            
            scrollViewHeight?.constant = size.height
            
            if let dropZone = self.dropZone , size.width > 0 , size.height > 0 {
                scrollView?.zoomScale = max(dropZone.bounds.size.width/size.width, dropZone.bounds.size.height/size.height )
            }
            
        }
    }
    
    //canHandle -> sessionUpdate -> PerformDrop
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        
        return UIDropProposal(operation: .copy)
    }
    
    
    var imageFetcher : ImageFetcher!
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        imageFetcher = ImageFetcher(){ (url,image) in
            DispatchQueue.main.async {
                //Making var of UIImage a tuple
                /* Why make it tuple?
                 Because I want url and image to always be set together I dont want to set accidentally set the URL and be image be different
                 So I am always gonna set them together
                 */
                self.emojiArtBackImage = (url,image)
                
                // in addition to emoji being added in our EmojiArtView
                // causing our document to change
                // whenever a new background image is dropped
                // our document changes as well
                // so we note that
                self.documentChanged()
            }
        }
        
        
        session.loadObjects(ofClass: NSURL.self) { (nsurls) in
            if let url = nsurls.first as? URL{
                self.imageFetcher.fetch(url)
            }
        }
        session.loadObjects(ofClass: UIImage.self) { (images) in
            
            if let image = images.first as? UIImage{
                self.imageFetcher.backup = image
            }
            
            
        }
    }
    
    @IBOutlet weak var emojiCollectionView: UICollectionView!{
        didSet{
            emojiCollectionView.dataSource = self
            
            emojiCollectionView.delegate = self
            
            emojiCollectionView.dragDelegate = self
            
            emojiCollectionView.dropDelegate = self
            
            //This is byDefault true on iPad but false on iPhone
            emojiCollectionView.dragInteractionEnabled = true
        }
    }
    
    //map just takes in an collection and turn's it into an array where it executes a closure on each of the element
    var emojis = "🍭👻🤪🧞‍♂️🦊🦄🐝🦍🐉🐲🍩⚽️✈️".map { String($0)}
    
    // so there are 3 required numberOfItemsInSection,cellForItemAt , numberOfSection
    // we dont want to implement numberOfScetions as it defaults to 1 that's true for tableView and collectionView
    
    private var addingEmoji = false
    
    @IBAction func addEmoji() {
        addingEmoji = true
    
        //Now Section 0 gonna be plus button or textfield depending on if I am adding emoji at the time
        //And section 1 gonna be all emojis
    emojiCollectionView.reloadSections(IndexSet(integer: 0))
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch  section {
        case 0:  return 1
        case 1:  return emojis.count
        default: return 0
        }

    }
    
    //MARK:- Dynamic Font accessibility UIFontMetrics Accessbility
    private var font : UIFont  {
        
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(64.0))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 1{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
        
        if let emojiCell = cell as? EmojiCollectionViewCell{
            
            let text = NSAttributedString(string: emojis[indexPath.item], attributes: [.font : font])
            
            emojiCell.label.attributedText = text
        }
        
        return cell
        }
        else if addingEmoji{
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiInputCell", for: indexPath)
            
            if let inputCell = cell as? TextFieldCollectionViewCell{
                
                //MARK:- Calling closure mentioned in TextFieldCollectionViewCell
                //Gonna set it to closure that does what I want
                inputCell.resignationHandler = { [weak self , unowned inputCell] in
                    
                    if let text = inputCell.textField.text{
                        
                        self?.emojis = (text.map{String($0)} + self!.emojis).uniquified
                        
                        //Oh self does it cause a memory cycle or does it cause a multi threaded issue...???
                        //There's no multithreaded issue here because we dont have problem with cells that scrolled off and scrolled back on
                        // But there's a memory cycle here
                        
                        //because self is ourselve as a viewcontroller and we point to our collectionView , our collectionView points to its cells , its cell points to this closure and this closure points backs to ourselves so its going round and round
                        //So we have to break this with weak self
                        
                        //But theres another memory cycle here
                        //Sometimes it says about self that doesnt mean there might not be another 1 in there
                        //And there is an another one its "inputCell"
                        //This var inputCell and I am using it in closure which will capture it and yet its pointing to the closure to resignation handler so this has to broken as well
                        //This 1 we can break with unowned , because we  know we would never be inside this closure executing it if "inputcell" is nil
                        
                        
                        self?.addingEmoji = false
                        
                        //Why reloadData because we just added emoji to our model
                        //And anytime you change your model you need to update your table
                        self?.emojiCollectionView.reloadData()
                        //reload cause it to go look at my new model call all the functions of collectionview
                        
                    }
                    
                }
                
            }
            
        return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddEmojiButtonCell", for: indexPath)
            return cell
        }
        
        
    }
    
    // MARK:- CollectionViewFlowlayout
    //For making cell size bigger where we want textField
    //Should calculate those blue number for width height based on user accessibility font size and all stuff
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if addingEmoji && indexPath.section == 0{
            // If we are having textfield then we are having wide cell
            return CGSize(width: 300, height: 80)
            
        }
        
        else {
            
            return CGSize(width: 80, height: 80)
            
        }
        
    }
    
    //Called right before it displays a cell
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let inputcell = cell as? TextFieldCollectionViewCell{
            
            // to make textfield first responder this way when the textField comes up the keyboard comes up
            inputcell.textField.becomeFirstResponder()
            
        }
        
    }
    
    //MARK:- UICollectionViewDragDelegate
    
    // itemsForBeginning is the thing that tells dragging system here's what we are dragging  , so we have to provide dragItem to drag
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        //MARK: - Context of Session to track who is it
        session.localContext = collectionView
        
        return dragItems(at : indexPath)
    }
    
    // So remember you can start a drag and add more items by tapping on them so you could be dragging multiple things at once that's easy to implement as well just like we have item
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at : indexPath)
    }
    
    private func dragItems(at indexPath : IndexPath)-> [UIDragItem]{
        //disabled dragging when adding emoji i.e. textfield and keyboard is up because it messes things up when we are swapping things up so took that out
        if  !addingEmoji, let attributedString = (emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.label?.attributedText {

            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString))

            dragItem.localObject = attributedString
            
            return [dragItem]
        }
        else{
            return []
        }
        
    }
    
    //MARK:- UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        // if dropped on emoji section its fine not on adding section so cancel
        //That is not allowing drop in section 0
        if let indexPath = destinationIndexPath , indexPath.section == 1 {
            
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy , intent: .insertAtDestinationIndexPath)
        }
        else{
            // cancel drop if section is not 1
            return UICollectionViewDropProposal(operation: .cancel)
            
        }
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {

        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)

        for item in coordinator.items{
            if let sourceindexPath = item.sourceIndexPath{

                if let dragItem = item.dragItem.localObject as? NSAttributedString {

                    collectionView.performBatchUpdates({
                        
                        emojis.remove(at: sourceindexPath.item)
                        emojis.insert(dragItem.string, at: destinationIndexPath.item)
                        
                        
                        collectionView.deleteItems(at: [sourceindexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                        
                    })
                    
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
                
            }
            else{
                                let placeHolderContext  = coordinator.drop(
                                    item.dragItem,
                                    to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholderCell")
                                )

                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { (provider, error) in

                    DispatchQueue.main.async {
                        
                        if let attributedString = provider as? NSAttributedString{
                        placeHolderContext.commitInsertion(dataSourceUpdates: { (insertionIndexPath) in
       
                            self.emojis.insert(attributedString.string, at: insertionIndexPath.item)
                        })
                        }
                        else{

                            placeHolderContext.deletePlaceholder()
                        }
                    
                    }

                }

            }
        }
    }

}



/*
So lets go to reading everytime it puts its view controller up
 ViewwillAppear will do it in
 It looks for untitled.json  and loads it up that way everytime we run our app  it wont be blank everytime
 
 It will just loada the last document we were working on Untitled.json that we where working on
 Let's  do that
  */


/*
 Done with maaking existing app work with UIDocument
 So UIDocument is doing all stuffs that FileSystem was doing for us
 But using UIDocument we can have our app launch show the file choosing thing , file broswer thing like files app
 removing viewDidload because we are not setting the  document = EmojiArtDocument(fileURL: url)
 because we want to set it to the whatever the document the user chooses
 */

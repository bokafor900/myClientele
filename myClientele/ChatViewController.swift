//
//  ChatViewController.swift
//  myClientele
//
//  Created by Bryan Okafor on 5/11/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit

class ChatViewController: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let ref = Firebase(url: "https://myclientele.firebaseio.com/Message")
    
    var messages: [JSQMessage] = []
    var objects: [NSDictionary] = []
    var loaded: [NSDictionary] = []
    
    var avatarImagesDictionary: NSMutableDictionary?
    var avatarDictionary: NSMutableDictionary?
    
    var showAvatars: Bool = true
    var firstLoad: Bool?
    
    var withUser: BackendlessUser?
    var recent: NSDictionary?
    
    var chatRoomId: String!
    
    var initialLoadComplete: Bool = false
    
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())

    override func viewDidLoad() {
        super.viewDidLoad()

        self.senderId = currentUser.objectId
        self.senderDisplayName = currentUser.name
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        if withUser?.objectId == nil {
            
            getWithUserFromRecent(recent!, result: { (withUser) -> Void in
                self.withUser = withUser
                self.title = withUser.name
                self.getAvatars()
            })
        } else {
            self.title = withUser!.name
            self.getAvatars()
        }
        
        //load firebase message
        loadMessages()
        
        self.inputToolbar?.contentView?.textView?.placeHolder = "New Message"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: JSQMessages dataSource functions
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let data = messages[indexPath.row]
        if data.senderId == currentUser.objectId {
            cell.textView?.textColor = UIColor.whiteColor()
        } else {
            cell.textView?.textColor = UIColor.blackColor()
        }
        
        return cell
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        let data = messages[indexPath.row]
        
        return data
        
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        
        
        if data.senderId == currentUser.objectId {
            return outgoingBubble
        } else {
            return incomingBubble
        }
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    

    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let message = objects[indexPath.row]
        let status = message["status"] as! String
        if indexPath.row == (messages.count - 1) {
            return NSAttributedString(string: status)
        } else {
            return NSAttributedString(string: "")
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        if outgoing(objects[indexPath.row]) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.row]
        let avatar = avatarDictionary!.objectForKey(message.senderId) as! JSQMessageAvatarImageDataSource
        
        return avatar
    }
    
    
    
    //MARK: JSQMEssages Delegate function
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        if text != "" {
            sendMessage(text, date: date, picture: nil, location: nil)
        }
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (alert: UIAlertAction) -> Void in
            camera.PresentPhotoCamera(self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .Default) { (alert: UIAlertAction!) -> Void in
            camera.PresentPhotoLibrary(self, canEdit: true)
        }

        let shareLocation = UIAlertAction(title: "Share Location", style: .Default) { (alert: UIAlertAction!) -> Void in
            if self.haveAccessToLocation() {
                self.sendMessage(nil, date: NSDate(), picture: nil, location: "location")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (alert : UIAlertAction!) -> Void in
            print("Cancel")
        }
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    
    }
    
    //MARK: Send Message
    
    func sendMessage(text: String?, date: NSDate, picture: UIImage?, location: String?) {
        
        var outgoingMessage = OutgoingMessage?()
        
        //if text message
        if let text = text {
            // send text message
            outgoingMessage = OutgoingMessage(message: text, senderId: currentUser.objectId!, senderName: currentUser.name!, date: date, status: "Delivered", type: "text")
        }
        
        //send picture message
        if let pic = picture {
            // send picture message
            let imageData = UIImageJPEGRepresentation(pic, 1.0)
            
            outgoingMessage = OutgoingMessage(message: "Picture", pictureData: imageData!, senderId: currentUser.objectId!, senderName: currentUser.name!, date: date, status: "Delivered", type: "picture")
        }
        
        if let loc = location {
            //senf location message
            let lat: NSNumber = NSNumber(double: (appDelegate.coordinate?.latitude)!)
            let lng: NSNumber = NSNumber(double: (appDelegate.coordinate?.longitude)!)
            
            outgoingMessage = OutgoingMessage(message: "Location", latitude: lat, longitude: lng, senderId: currentUser.objectId!, senderName: currentUser.name, date: date, status: "Delivered", type: "location")
        }
        
        //play message sent sound
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        outgoingMessage!.sendMessage(chatRoomId, item: outgoingMessage!.messageDictionary)
    }
    
    //MARK: Load Messages
    
    func loadMessages() {
        
        ref.childByAppendingPath(chatRoomId).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
         
            //get dictionaries
            
            //create JSQ mesaages
            
            self.insertMessages()
            self.finishReceivingMessageAnimated(true)
            self.initialLoadComplete = true
        })
        
        ref.childByAppendingPath(chatRoomId).observeEventType(.ChildAdded, withBlock: {
            snapshot in
         
            if snapshot.exists() {
                let item = (snapshot.value as? NSDictionary)!
                
                if self.initialLoadComplete {
                    let incoming = self.insertMessage(item)
                    
                    if incoming {
                        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    }
                    
                    self.finishReceivingMessageAnimated(true)
                    
                } else {
                    // add each dictionary to loaded array
                    self.loaded.append(item)
                }
                
            }
        })
        
        ref.childByAppendingPath(chatRoomId).observeEventType(.ChildChanged, withBlock: {
            snapshot in
            
            //update message
        })
        
        ref.childByAppendingPath(chatRoomId).observeEventType(.ChildRemoved, withBlock: {
            snapshot in
            
            //Delete message
        })
    }
    
    func insertMessages() {
        
        for item in loaded {
            //create message
            insertMessage(item)
        }
    }
    
    func insertMessage(item: NSDictionary) -> Bool {
        
        let incomingMessage = IncomingMessage(colletionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(item)
        
        objects.append(item)
        messages.append(message!)
        
        return incoming(item)
        
    }
    
    func incoming(item: NSDictionary) -> Bool {
        
        if self.senderId == item["senderId"] as! String {
            return false
        } else {
            return true
        }
        
    }
    
    func outgoing(item: NSDictionary) -> Bool {
        
        if self.senderId == item["senderId"] as! String {
            return true
        } else {
            return false
        }
        
    }
    
    //MARK: Helper function
    
    func haveAccessToLocation() -> Bool {
        if let _ = appDelegate.coordinate?.latitude {
            return true
        } else {
            return false
        }
    }
    
    func getAvatars() {
        if showAvatars {
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(30, 30)
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSizeMake(30, 30)
            
            //download avatars
            avatarImageFromBackendlessUser(currentUser)
            avatarImageFromBackendlessUser(withUser!)
            
            //create avatars
            createAvatars(avatarImagesDictionary)
        }
    }
    
    func getWithUserFromRecent(recent: NSDictionary, result: (withUser: BackendlessUser) -> Void) {
        let withUserId = recent["withUserUserId"] as? String
        
        let whereClause = "objectId = '\(withUserId!)'"
        let dataQuery = BackendlessDataQuery()
        dataQuery.whereClause = whereClause
        
        let dataStore = backendless.persistenceService.of(BackendlessUser.ofClass())
        
        dataStore.find(dataQuery, response: { (users : BackendlessCollection!) -> Void in
            let withUser = users.data.first as! BackendlessUser
            result(withUser: withUser)
            }) { (fault : Fault!) -> Void in
                print("Server reported an error : \(fault)")
        }
        
    }
    
    func createAvatars(avatars: NSMutableDictionary?) {
        var currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage (named: "avatarPlaceholder"), diameter: 70)
        var withUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage (named: "avatarPlaceholder"), diameter: 70)
        
        if let avat = avatars {
            if let currentUserAvatarImage = avat.objectForKey(currentUser.objectId) {
                currentUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: currentUserAvatarImage as! NSData), diameter: 70)
                self.collectionView?.reloadData()
            }
        }
        
        if let avat = avatars {
            if let withUserAvatarImage = avat.objectForKey(withUser!.objectId!) {
                withUserAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: withUserAvatarImage as! NSData), diameter: 70)
                self.collectionView?.reloadData()
            }
        }
        
        avatarDictionary = [currentUser.objectId : currentUserAvatar, withUser!.objectId! : withUserAvatar]
    }
    // if have image user is going to replace it with the new one
    func avatarImageFromBackendlessUser(user: BackendlessUser)  {
        if let imageLink = user.getProperty("Avatar") {
            getImageFromURL(imageLink as! String, result: { (image) -> Void in
                let imageData = UIImageJPEGRepresentation(image!, 1.0)
                if self.avatarImagesDictionary != nil {
                    self.avatarImagesDictionary!.removeObjectForKey(user.objectId)
                    self.avatarImagesDictionary!.setObject(imageData!, forKey: user.objectId)
                } else {
                    self.avatarImagesDictionary = [user.objectId! : imageData!]
                }
                self.createAvatars(self.avatarImagesDictionary)
            })
        }
    }
    
    //MARK: JSQDelegate function
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        let object = objects[indexPath.row]
        
        if object["type"] as! String == "picture" {
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! JSQPhotoMediaItem

            let photos = IDMPhoto.photosWithImages([mediaItem.image])
            let browser = IDMPhotoBrowser(photos: photos)
            
            self.presentViewController(browser, animated: true, completion: nil)
        }
        
        if object["type"] as! String == "location" {
            
            self.performSegueWithIdentifier("chatToMapSeg", sender: indexPath)
        }
        
    }
    
    //MARK: UIImagePickerController functions
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let picture = info[UIImagePickerControllerEditedImage] as! UIImage
        
        self.sendMessage(nil, date: NSDate(), picture: picture, location: nil)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "chatToMapSeg" {
            
            let indexPath = sender as! NSIndexPath
            let message = messages[indexPath.row]
            
            let mediaItem = message.media as! JSQLocationMediaItem
            
            let mapView = segue.destinationViewController as! mapVC
            mapView.location = mediaItem.location
        }
    }

}

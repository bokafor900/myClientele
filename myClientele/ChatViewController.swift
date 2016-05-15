//
//  ChatViewController.swift
//  myClientele
//
//  Created by Bryan Okafor on 5/11/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import UIKit

class ChatViewController: JSQMessagesViewController {
    
    let ref = Firebase(url: "https://myclientele.firebaseio.com/Messgae")
    
    var messages: [JSQMessage] = []
    var objects: [NSDictionary] = []
    var loaded: [NSDictionary] = []
    
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
    
    //MARK: JSQMEssages Delegate function
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        if text != "" {
            //send our message
            sendMessage(text, date: date, picture: nil, location: nil)
        }
        
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        print("accessory button pressed")
    
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
        }
        
        if let loc = location {
            //senf location message
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
    
    
    


}

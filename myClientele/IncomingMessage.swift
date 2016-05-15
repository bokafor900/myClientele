//
//  IncomingMessage.swift
//  myClientele
//
//  Created by Bryan Okafor on 5/14/16.
//  Copyright © 2016 Oaks. All rights reserved.
//

import Foundation

class IncomingMessage {
    
    var collectionView: JSQMessagesCollectionView
    
    init(colletionView_: JSQMessagesCollectionView) {
        
        collectionView = colletionView_
    }
    
    func createMessage(dictionary: NSDictionary) -> JSQMessage? {
        
        var message: JSQMessage?
        
        let type = dictionary["type"] as? String
        
        if type == "text" {
            // create text message
            message = createTextMessage(dictionary)
        }
        if type == "location" {
            //create location message
        }
        if type == "picture" {
            //create picture message
        }
        
        if let mes = message {
            return mes
        }
        
        return nil
    }
    
    func createTextMessage(item: NSDictionary) -> JSQMessage {
        
        let name = item["senderName"] as? String
        let userId = item["senderId"] as? String
        
        let date = dateFormatter().dateFromString((item["date"] as? String)!)
        let text = item["message"] as? String
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }
}

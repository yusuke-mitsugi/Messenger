//
//  ConversationModels.swift
//  Messenger
//
//  Created by Yusuke Mitsugi on 2020/06/27.
//  Copyright © 2020 Yusuke Mitsugi. All rights reserved.
//

import Foundation


struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

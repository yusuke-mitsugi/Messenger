//
//  ProfileViewModel.swift
//  Messenger
//
//  Created by Yusuke Mitsugi on 2020/06/27.
//  Copyright © 2020 Yusuke Mitsugi. All rights reserved.
//

import Foundation



enum profileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: profileViewModelType
    let title: String
    let handler: (() -> Void)?
}

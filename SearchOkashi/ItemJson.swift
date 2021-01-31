//
//  ItemJson.swift
//  SearchOkashi
//
//  Created by 城野 on 2021/01/31.
//

import Foundation

struct ItemJson: Codable {
    
    let name: String?
    
    let maker: String?
    
    let url: URL?
    
    let image: URL?
    
}

struct ResultJson: Codable {
    
    let item:[ItemJson]?
    
}


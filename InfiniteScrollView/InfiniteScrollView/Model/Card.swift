//
//  Card.swift
//  InfiniteScrollView
//
//  Created by SamsonCJ on 2025/2/25.
//

import SwiftUI

let cards = [Card(image:  "pic1"),Card(image: "pic2"),Card(image: "pic3"), Card(image: "pic4"),Card(image: "pic5")]

struct Card: Identifiable, Hashable {
    var image: String
    var id: String = UUID().uuidString

}


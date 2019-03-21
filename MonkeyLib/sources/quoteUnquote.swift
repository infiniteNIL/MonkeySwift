//
//  quoteUnquote.swift
//  Monkey
//
//  Created by Rod Schmidt on 3/20/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

func quote(_ node: Node) -> MonkeyObject {
    return MonkeyQuote(node: node)
}

//
//  Canteen.swift
//  server
//
//  Created by Lars Winzer on 20.12.25.
//

import Foundation

struct Canteen {
    let id: UUID
    let name: String
    let `operator`: CanteenOperator
    let address: Address
}

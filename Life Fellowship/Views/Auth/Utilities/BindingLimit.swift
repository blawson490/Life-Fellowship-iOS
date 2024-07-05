//
//  BindingLimit.swift
//  Life Fellowship
//
//  Created by Blake Lawson on 7/5/24.
//

import SwiftUI

extension Binding where Value == String{
    func limit(_ length: Int)->Self{
        if self.wrappedValue.count > length{
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(length))
            }
        }
        return self
    }
}

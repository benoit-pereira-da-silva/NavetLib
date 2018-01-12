//
//  Int+Padding.swift
//  navet
//
//  Created by Benoit Pereira da silva on 27/10/2017.
//  Copyright © 2017 Pereira da Silva https://pereira-da-silva.com All rights reserved.
//

import Foundation

extension Int{

    func paddedInt(numberOfDigit: Int=3)->String {
        var s="\(self)"
        while s.count < numberOfDigit {
            s="0"+s
        }
        return s
    }

}

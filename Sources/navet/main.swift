//
//  main.swift
//  navet
//
//  Created by Benoit Pereira da silva on 27/10/2017.
//  Copyright © 2017 Pereira da Silva https://pereira-da-silva.com All rights reserved.
//

import Foundation

let facade=CommandsFacade()
facade.actOnArguments()

var holdOn=true
let runLoop=RunLoop.current
while (holdOn && runLoop.run(mode: RunLoopMode.defaultRunLoopMode, before: NSDate.distantFuture) ) {}

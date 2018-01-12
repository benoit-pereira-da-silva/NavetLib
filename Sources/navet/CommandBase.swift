//
//  CommandBase.swift
//  navet
//
//  Created by Benoit Pereira da silva on 27/10/2017.
//  Copyright © 2017 Pereira da Silva https://pereira-da-silva.com All rights reserved.
//

import Foundation
import CommandLineKit
import NavetLib

public class CommandBase {

    public var isVerbose=true

    private let _cli = CommandLine()

    func addOptions(options: Option...) {
        for o in options {
            _cli.addOption(o)
        }
    }

    func parse() -> Bool {
        do {
            try _cli.parse()
            return true
        } catch {
            _cli.printUsage()
            exit(EX_USAGE)
        }
    }

    func printVerbose(string: String) {
        if isVerbose {
            self.printVersatile(string: string)
        }
    }

    func printVersatile(string: String) {
        print(string)
    }

}


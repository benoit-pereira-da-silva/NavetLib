//
//  CommandFacade.swift
//  navet
//
//  Created by Benoit Pereira da silva on 27/10/2017.
//  Copyright © 2017 Pereira da Silva https://pereira-da-silva.com All rights reserved.
//

import Cocoa
import NavetLib

public struct CommandsFacade {

    static let args = Swift.CommandLine.arguments
    let executableName = NSString(string: args.first!).pathComponents.last!
    let firstArgumentAfterExecutablePath: String = (args.count >= 2) ? args[1] : ""

    let echo: String = args.joined(separator: " ")

    public func actOnArguments() {

        switch firstArgumentAfterExecutablePath {
        case nil:
            print(self._noArgMessage())
            exit(EX_NOINPUT)
        case "-h", "-help", "h", "help":
            print(self._noArgMessage())
            exit(EX_USAGE)
        case "-version", "--version", "v", "version":
            print("\n\"navet\" has been created by Benoit Pereira da Silva https://pereira-da-silva.com\nCurrent version of Navet is: \(Navet.version)")
            exit(EX_USAGE)
        case "echo", "--echo":
            print(echo)
            exit(EX_USAGE)
        case "generate":
            let _ = NavetGenerate()
        default:
            // We want to propose the best verb candidate
            let reference=[
                "h", "help",
                "v","version",
                "echo",
                "generate"
            ]
            let bestCandidate=self.bestCandidate(string: firstArgumentAfterExecutablePath, reference: reference)
            print("Hey ...\"\(executableName) \(firstArgumentAfterExecutablePath)\" is unexpected!")
            print("Did you mean:\"\(executableName) \(bestCandidate)\"?")
            exit(EX__BASE)
        }
    }

    private func _noArgMessage() -> String {
        var s=""
        s += "Navet Command Line tool"
        s += "\nCreated by Benoit Pereira da Silva https://pereira-da-silva.com"
        s += "\nvalid calls are S.V.O sentences like:\"\(executableName) <verb> [options]\""
        s += "\n"
        s += "\n\(executableName) help"
        s += "\n\(executableName) version"
        s += "\n\(executableName) echo <args>"
        s += "\n"
        s += "\nYou can call help for each verb e.g:\t\"\(executableName) generate help\""
        s += "\n"
        s += "\nAvailable verbs:"
        s += "\n"
        s += "\n\(executableName) generate -d <duration> -f <fps> [options]"
        s += "\n"
        return s
    }

    // MARK: levenshtein distance

    private func bestCandidate(string: String, reference: [String]) -> String {
        guard string != "" else {
            return "help"
        }
        var selectedCandidate=string
        var minDistance: Int=Int.max
        for candidate in reference {
            let distance=self.levenshtein(string, candidate)
            if distance<minDistance {
                minDistance=distance
                selectedCandidate=candidate
            }
        }
        return selectedCandidate
    }

    private func min(numbers: Int...) -> Int {
        return numbers.reduce(numbers[0], {$0 < $1 ? $0 : $1})
    }

    private class Array2D {
        var cols: Int, rows: Int
        var matrix: [Int]

        init(cols: Int, rows: Int) {
            self.cols = cols
            self.rows = rows
            matrix = Array(repeating:0, count:cols*rows)
        }

        subscript(col: Int, row: Int) -> Int {
            get {
                return matrix[cols * row + col]
            }
            set {
                matrix[cols*row+col] = newValue
            }
        }

        func colCount() -> Int {
            return self.cols
        }

        func rowCount() -> Int {
            return self.rows
        }
    }

    private func levenshtein(_ aStr: String, _ bStr: String) -> Int {
        let a = Array(aStr.utf16)
        let b = Array(bStr.utf16)

        let dist = Array2D(cols: a.count + 1, rows: b.count + 1)
        for i in 1...a.count {
            dist[i, 0] = i
        }

        for j in 1...b.count {
            dist[0, j] = j
        }

        for i in 1...a.count {
            for j in 1...b.count {
                if a[i-1] == b[j-1] {
                    dist[i, j] = dist[i-1, j-1]  // noop
                } else {
                    dist[i, j] = min(numbers:
                        dist[i-1, j] + 1,  // deletion
                        dist[i, j-1] + 1,  // insertion
                        dist[i-1, j-1] + 1  // substitution
                    )
                }
            }
        }
        return dist[a.count, b.count]
    }
}


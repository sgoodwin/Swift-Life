//
//  ViewController.swift
//  Life
//
//  Created by Samuel Ryan Goodwin on 10/24/16.
//  Copyright © 2016 Roundwall Software. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var boardView: BoardView!
    
    var timer: Timer?
    
    private func makeTimer() -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 0.30, repeats: true, block: step)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.board = Board()
    }
    
    @IBAction func step(_ sender: Any) {
        board = board?.next()
    }
    
    @IBAction func play(_ sender: Any) {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        } else {
            timer = makeTimer()
            timer?.fire()
        }
    }
    
    var board: Board? {
        didSet {
            (view as! BoardView).board = board
        }
    }
}

typealias Cell = Bool

struct Board: CustomDebugStringConvertible {
    private let cells: [[Cell]]
    
    var width: Int {
        return cells[0].count
    }
    
    var height: Int {
        return cells.count
    }
    
    init() {
        self.cells = [
            [false, false, false, false, false, false, false, true,  false, false, true, false, false, true, false ,true],
            [false, false, false, false, false, false, true,  false, false, false, true, false, false, false, false, true],
            [false, false, false, false, false, false, true,  true,  true, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
            [false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false],
        ]
    }
    
    init(rows: [[Cell]]) {
        self.cells = rows
    }
    
    subscript(row: Int, column: Int) -> Cell? {
        if row < 0 {
            return nil
        }
        if column < 0 {
            return nil
        }
        if row >= height {
            return nil
        }
        if column >= width {
            return nil
        }
        return cells[row][column]
    }
    
    public var debugDescription: String {
        return "\n" + cells.map({ ($0.map { $0 ? "X" : " " }).joined(separator: " ") }).joined(separator: "\n"
            ) + "\n"
    }
    
    func next() -> Board {
        var rows = [[Cell]]()
        for rowNumber in 0..<height {
            var row = [Cell]()
            for colNumber in 0..<width {
                let cell = self[rowNumber, colNumber]!
                
                switch livingNeighbors(row: rowNumber, column: colNumber) {
                case 0..<2:
                    row.append(false)
                case 3:
                    if cell == false {
                        row.append(true)
                    } else {
                        row.append(cell)
                    }
                case 2, 3:
                    row.append(cell)
                default:
                    row.append(false)
                }
            }
            rows.append(row)
        }
        
        return Board(rows: rows)
    }
    
    private func livingNeighbors(row: Int, column: Int) -> Int {
        var count = 0
        if self[row, column+1] ?? false {
            count += 1
        }
        if self[row+1, column+1] ?? false{
            count += 1
        }
        if self[row+1, column] ?? false{
            count += 1
        }
        if self[row+1, column-1] ?? false{
            count += 1
        }
        if self[row, column-1] ?? false{
            count += 1
        }
        if self[row-1, column-1] ?? false{
            count += 1
        }
        if self[row-1, column] ?? false{
            count += 1
        }
        if self[row-1, column+1] ?? false{
            count += 1
        }
        return count
    }
}

class BoardView: NSView {
    var board: Board? {
        didSet {
            setNeedsDisplay(bounds)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let board = board else {
            return
        }
        
        let width = bounds.width/CGFloat(board.width)
        let height = bounds.height/CGFloat(board.height)
        
        for y in 0..<board.height {
            for x in 0..<board.width {
                let cell = board[y, x]!
                
                let box = CGRect(x: CGFloat(x)*width, y: CGFloat(y)*height, width: width, height: height)
                let path = NSBezierPath(rect: box)
                if cell {
                    NSColor.green.setFill()
                } else {
                    NSColor.white.setFill()
                }
                path.fill()
            }
        }
    }
}


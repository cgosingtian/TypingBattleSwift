//
//  WordList.swift
//  TypingBattleSwift
//
//  Created by Chase Gosingtian on 10/31/14.
//  Copyright (c) 2014 KLab Cyscorpions, Inc. All rights reserved.
//

import Foundation

private let EasyWords : [String] = ["Chase","RB","Taki","Anne","Ram","Regie","Erica"]

private let MediumWords : [String] = ["Chase G","RB D G","Taki B","Anne P","Ram L","Regie P","Erica C"]

private let HardWords : [String] = ["Chase Gosingtian","Robert Benedict","Katreena Bacalso",
    "Anne Pabustan","Christian Lazatin","Regie Pinat","Erica Caber"]

internal enum Difficulties : Int {
    case Easy = 0, Medium = 1, Hard = 2
    
    func random() -> Difficulties {
        let difficultyIndices:UInt32 = 2
        // Range is from 0 to difficultyIndices, inclusive
        return Difficulties(rawValue: Int( arc4random_uniform( difficultyIndices  ) ) )!
    }
}

internal class WordList {
    internal var difficulty : Difficulties {
        didSet {
            println("Changing difficulty to \(self.difficulty.rawValue.description)")
        }
    }

    //MARK - Initializers
    init() {
        self.difficulty = Difficulties.Easy
    }
    init(difficulty : Difficulties) {
        self.difficulty = difficulty
    }
    
    //MARK - Getters
    internal func wordList() -> [String]
    {
        switch (difficulty)
        {
        case .Easy:
            return EasyWords
        case .Medium:
            return MediumWords
        case .Hard:
            return HardWords
        }
    }
}
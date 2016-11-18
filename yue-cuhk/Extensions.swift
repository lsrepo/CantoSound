//
//  Extensions.swift
//  yue-cuhk
//
//  Created by Pak on 2016-11-17.
//  Copyright © 2016 pakwlau.com. All rights reserved.
//

import Foundation

class Sense{
    let syllable:String
    let homophones:[String]
    let explanation:String
    
    init(syllable:String, homophones:[String], explanation:String) {
        self.syllable = syllable
        self.homophones = homophones
        self.explanation = explanation
    }
}

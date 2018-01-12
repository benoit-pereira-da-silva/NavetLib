//
//  CMTime+Representation.swift
//  navet
//
//  Created by Benoit Pereira da silva on 27/10/2017.
//  Copyright © 2017 Pereira da Silva https://pereira-da-silva.com All rights reserved.
//
#if os(OSX)
import CoreMedia
import Cocoa

extension CMTime{

    func timeCodeRepresentation(_ fps: Double,showImageNumber:Bool=true)->String {
        let r=self.timeCodeComponents(fps)
        var imagePadding=1
        if fps > 10 && fps < 100 {
            imagePadding=2
        } else if fps > 100 {
            imagePadding=3
        }
        if showImageNumber{
            return "\(r.hours.paddedInt(numberOfDigit: 2)):\(r.minutes.paddedInt(numberOfDigit: 2)):\(r.seconds.paddedInt(numberOfDigit: 2)):\(r.imageNumber.paddedInt(numberOfDigit: imagePadding))"
        }else{
            return "\(r.hours.paddedInt(numberOfDigit: 2)):\(r.minutes.paddedInt(numberOfDigit: 2)):\(r.seconds.paddedInt(numberOfDigit: 2))"
        }
    }

    func timeCodeComponents(_ fps: Double)->(hours: Int, minutes: Int, seconds: Int, imageNumber: Int, fps: Double) {
        guard fps != 0 else{
            return ( 0,0,0,0, fps)
        }
        let hours = Int(self.seconds) / 3600
        let minutes = Int(self.seconds) / 60 % 60
        let nbOfSeconds = Int(self.seconds) % 60
        let frameDuration = 1 / fps
        let numberOfImage = floor(self.seconds.truncatingRemainder(dividingBy: 1) / frameDuration) // floor is absolutely required
        return (Int(hours), Int(minutes), Int(nbOfSeconds), Int(numberOfImage), fps)
    }
}
#endif

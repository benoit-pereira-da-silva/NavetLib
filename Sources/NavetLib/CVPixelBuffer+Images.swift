//
//  CVPixelBuffer+Images.swift
//  navet
//
//  Created by Benoit Pereira da silva on 27/10/2017.
//  Copyright © 2017 Pereira da Silva https://pereira-da-silva.com All rights reserved.
//

#if os(OSX)
import Foundation
import CoreVideo

extension CVPixelBuffer {

    func drawCGImage(_ image: CGImage) {
       CVPixelBufferLockBaseAddress(self, [])
        let bitmapContext = CGContext(
            data: CVPixelBufferGetBaseAddress(self)!,
            width: CVPixelBufferGetWidth(self),
            height: CVPixelBufferGetHeight(self),
            bitsPerComponent: 8,
            bytesPerRow:  CVPixelBufferGetBytesPerRow(self),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        let point = CGPoint(x: 0, y: 0)
        let size = CGSize(width: CVPixelBufferGetWidth(self), height: CVPixelBufferGetHeight(self))
        let rect = CGRect(origin:point, size: size)
        bitmapContext?.draw(image, in: rect)
        CVPixelBufferUnlockBaseAddress(self, [])
    }
}
#endif

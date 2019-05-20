//
//  Utilities.swift
//  UniPlayer
//
//  Created by Martin Zörfuss on 20.05.19.
//  Copyright © 2019 Martin Zörfuss. All rights reserved.
//

import UIKit

class Utilities {
    public static  func createIcon(for image: UIImage, imageView: UIImageView, background color: UIColor, imgFactor: CGFloat = 0.6) -> UIImage {
        
        let sizeImg = imageView.bounds.height * imgFactor
        let size = imageView.bounds.height * 0.7
        let imgView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: sizeImg, height: sizeImg)))
        
        let v = UIView(frame: CGRect(origin: .zero, size: CGSize(width: size, height: size)))
        v.addSubview(imgView)
        v.layer.masksToBounds = true
        v.layer.cornerRadius = 7
        v.backgroundColor = color
        imgView.center = v.center
        imgView.image = image
        
        imgView.tintColor = imageView.tintColor
        
        UIGraphicsBeginImageContextWithOptions(v.bounds.size, false, 3)
        v.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
}

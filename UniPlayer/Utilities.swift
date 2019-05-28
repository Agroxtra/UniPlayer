//
//  Utilities.swift
//  UniPlayer
//
//  Created by Martin Zörfuss on 20.05.19.
//  Copyright © 2019 Martin Zörfuss. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb:Int) {
        self.init(red:(rgb >> 16) & 0xff, green:(rgb >> 8) & 0xff, blue:rgb & 0xff)
    }
}


class Utilities {
    public static  func addBorder(for image: UIImage, imageView: UIImageView, background color: UIColor, imgFactor: CGFloat = 0.6, cornerRadius: CGFloat = 7) -> UIImage {
        
        let sizeImg = imageView.bounds.height * imgFactor
        let size = imageView.bounds.height/* * 0.7*/
        let imgView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: sizeImg, height: sizeImg)))
        imgView.layer.masksToBounds = true
        imgView.layer.cornerRadius = cornerRadius
        let v = UIView(frame: CGRect(origin: .zero, size: CGSize(width: size, height: size)))
        v.addSubview(imgView)
//        v.layer.masksToBounds = true
//        v.layer.cornerRadius = cornerRadius
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
    
    public static func createArtworkBorder(for song: Song, imgView: UIImageView?) -> UIImage{
        return Utilities.addBorder(for: song.getArtwork(size: CGSize(width: 200, height: 200)), imageView: imgView ?? UIImageView(), background: .clear, imgFactor: 0.95, cornerRadius: 10)
    }
    
    public static func createArtworkBorder(for image: UIImage, imgView: UIImageView?) -> UIImage{
        return Utilities.addBorder(for: image, imageView: imgView ?? UIImageView(), background: .clear, imgFactor: 0.95, cornerRadius: 10)
    }
    
    public static func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
}

//
//  UIImageView+CacheLoader.swift
//  tawkto
//
//  Created by mac on 08/02/2022.
//

import UIKit


let imageCache = NSCache<NSString, UIImage>()
extension UIImageView {
    func loadImageUsingCache(withUrl urlString : String,isInverted: Bool = false) -> URLSessionDataTask? {
        var task: URLSessionDataTask
        let imageURLString = urlString
        let url = URL(string: urlString)
        if url == nil {return nil }
        self.image = nil

        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString)  {
            self.image = cachedImage
            return nil
        }

        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.init(style: .gray)
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.center = self.center

        // if not, download image from url
        task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    print(error!)
                }
               
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    if isInverted == true {
                        guard let newImage = self.invertImage(image: image) else { return }
                        imageCache.setObject(newImage, forKey: urlString as NSString)
                        self.image = newImage
                        activityIndicator.removeFromSuperview()
                    }else {
                        imageCache.setObject(image, forKey: urlString as NSString)
                        self.image = image
                        activityIndicator.removeFromSuperview()
                    }
                }
            }

        })
            task.resume()
        return task
    }
    
    func invertImage(image: UIImage) -> UIImage?{
//        let beginImage = CIImage(image: image)
//        if let filter = CIFilter(name: "CIColorInvert") {
//            filter.setValue(beginImage, forKey: kCIInputImageKey)
//            let newImage = UIImage(ciImage: filter.outputImage!)
//            return newImage
//
//        }else {
//            return nil
//        }
        
        let image = CIImage(cgImage: (image.cgImage)!)
        if let filter =  CIFilter(name: "CIColorInvert") {
            filter.setDefaults()
            filter.setValue(image, forKey: kCIInputImageKey)

            let context = CIContext(options: nil)
            guard let imageRef = context.createCGImage(filter.outputImage!, from: image.extent) else { return nil}
            return UIImage(cgImage: imageRef)
        
        }else {
            return nil
        }
    }
    
    
   
}

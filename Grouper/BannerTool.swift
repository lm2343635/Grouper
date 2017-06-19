//
//  Banner.swift
//  Grouper
//
//  Created by lidaye on 26/04/2017.
//  Copyright © 2017 limeng. All rights reserved.
//

import UIKit
import BRYXBanner

@objc class BannerTool: NSObject {
    
    class func show(title: String?, subtitle: String, image: UIImage?) {
        let banner = Banner(title: title,
                            subtitle: subtitle,
                            image: image,
                            backgroundColor: UIColor(red:89/255.0, green:215/255.0, blue:203/255.0, alpha:1))
        banner.dismissesOnTap = true
        banner.show(duration: 5.0)
    }

}

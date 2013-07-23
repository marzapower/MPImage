//
//  UIImage+MPImage.h
//  MPImage
//
//  Created by Daniele Di Bernardo on 30/01/13.
//  Copyright (c) 2013 marzapower. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MPImage)

- (UIImage *)imageWithDownwardShadow:(UIColor *)shadowColor;
- (UIImage *)imageWithOverColor:(UIColor *)color;
- (UIImage *)imageWithOverColorAndDownShadow:(UIColor *)color;
- (UIImage *)imageWithOverColor:(UIColor *)color downShadow:(UIColor *)shadowColor;

@end

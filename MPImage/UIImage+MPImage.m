//
//  UIImage+MPImage.m
//  MPImage
//
//  Created by Daniele Di Bernardo on 30/01/13.
//  Copyright (c) 2013 marzapower. All rights reserved.
//

#import "UIImage+MPImage.h"
#import "UIImage+MPAdditions.h"
#import <CoreImage/CoreImage.h>

@implementation UIImage (MPImage)

- (UIImage *)imageWithDownwardShadow:(UIColor *)shadowColor {
  int horizontalOffset = 1;
  int verticalOffset = 1;
  CGSize size = self.size;
  size.width += abs(horizontalOffset);
  size.height += abs(verticalOffset);
  UIGraphicsBeginImageContextWithOptions(size, NO, self.scale); {
    CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), CGSizeMake(horizontalOffset, verticalOffset), 0, shadowColor.CGColor);
    [self drawAtPoint:CGPointZero];
  }
  UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return resultImage;
}

- (UIImage *)imageWithOverColor:(UIColor *)color {
  // Tried to mirror down the image: no effects
  UIImage *mask;
  UIColor *shadowColor = [color colorDarkenedBy:0.2];
  //  mask = [UIImage imageWithCGImage:self.CGImage scale:self.scale orientation:UIImageOrientationDownMirrored];
  UIImage *invertedMask = [self invertedMaskWithMask:[self flattenGrayscaleImage] color:shadowColor];
  
  mask = self; //[self imageByReplacingColor:0x0 withColor:0xFFF];
  CGSize extended = mask.size;
  extended.width += 4;
  extended.height += 4;
  CGRect rect = {CGPointZero, extended};
  UIImage *resultImage;
  UIGraphicsBeginImageContextWithOptions(rect.size, NO, mask.scale*2); {
    CGContextRef gc = UIGraphicsGetCurrentContext();
    CGRect dim ={CGPointMake(2, 2), mask.size};
    CGContextClipToMask(gc, dim, mask.CGImage);
    mask = nil;
    [color setFill];
    CGContextFillRect(gc, rect);
  
    CGContextSetShadowWithColor(gc, CGSizeMake(1, -1), 2.5, [shadowColor colorWithAlphaComponent:0.8].CGColor);
    [invertedMask drawAtPoint:CGPointZero];
    invertedMask = nil;
    
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
  }
  UIGraphicsEndImageContext();
  
  // Mirroring the final image
  resultImage = [UIImage imageWithCGImage:resultImage.CGImage scale:resultImage.scale orientation:UIImageOrientationDownMirrored];
  return resultImage;
}

- (UIImage *)flattenImage {
  CIContext *context = [CIContext contextWithOptions:nil];
  CIFilter *filter= [CIFilter filterWithName:@"CIColorControls"];
  CIImage *inputImage = [[CIImage alloc] initWithImage:self];
  [filter setValue:inputImage forKey:@"inputImage"];
  [filter setValue:[NSNumber numberWithFloat:0] forKey:@"inputSaturation"];
  [filter setValue:[NSNumber numberWithFloat:0] forKey:@"inputBrightness"];
  [filter setValue:[NSNumber numberWithFloat:0] forKey:@"inputContrast"];
  CIImage *result = [filter valueForKey:kCIOutputImageKey];
  CGImageRef output = [context createCGImage:result fromRect:result.extent];
  UIImage *res = [UIImage imageWithCGImage:output];
  CGImageRelease(output);
  output = nil;
  return res;
}

- (UIImage *)invertedMaskWithMask:(UIImage *)mask color:(UIColor *)color {
  CGSize extended = mask.size;
  extended.width += 4;
  extended.height += 4;
  CGRect rect = {CGPointZero, extended};
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, mask.scale); {
      [color setFill];
      UIRectFill(rect);
      CGRect dim ={CGPointMake(2, 2), mask.size};
      CGContextClipToMask(UIGraphicsGetCurrentContext(), dim, mask.CGImage);
      CGContextClearRect(UIGraphicsGetCurrentContext(), rect);
    }
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

- (UIImage *)imageWithOverColorAndDownShadow:(UIColor *)color {
  return [[self imageWithOverColor:color] imageWithDownwardShadow:MP_GRAYA(255, 0.4)];
}

- (UIImage *)imageWithOverColor:(UIColor *)color downShadow:(UIColor *)shadowColor {
  return [[self imageWithOverColor:color] imageWithDownwardShadow:shadowColor];
}

@end

//
//  UIImage+MPAdditions.m
//  Sparrow
//
//  Created by Shilo White on 10/16/11.
//  Copyright 2011 Shilocity Productions. All rights reserved.
//

#import "UIImage+MPAdditions.h"

@implementation UIImage (MPAdditions)
- (UIImage *)imageByRemovingColor:(uint)color {
  return [self imageByRemovingColorsWithMinColor:color maxColor:color];
}

- (UIImage *)imageByRemovingColorsWithMinColor:(uint)minColor maxColor:(uint)maxColor {
  return [self imageByReplacingColorsWithMinColor:minColor maxColor:maxColor withColor:0 andAlpha:0];
}

- (UIImage *)imageByReplacingColor:(uint)color withColor:(uint)newColor {
  return [self imageByReplacingColorsWithMinColor:color maxColor:color withColor:newColor];
}

- (UIImage *)imageByReplacingColorsWithMinColor:(uint)minColor maxColor:(uint)maxColor withColor:(uint)newColor {
  return [self imageByReplacingColorsWithMinColor:minColor maxColor:maxColor withColor:newColor andAlpha:1.0f];
}

- (UIImage *)imageByReplacingColorsWithMinColor:(uint)minColor maxColor:(uint)maxColor withColor:(uint)newColor andAlpha:(CGFloat)alpha {
  CGImageRef imageRef = self.CGImage;
  CGFloat width = CGImageGetWidth(imageRef);
  CGFloat height = CGImageGetHeight(imageRef);
  CGRect bounds = CGRectMake(0, 0, width, height);
  uint minRed = COLOR_PART_RED(minColor);
  uint minGreen = COLOR_PART_GREEN(minColor);
  uint minBlue = COLOR_PART_BLUE(minColor);
  uint maxRed = COLOR_PART_RED(maxColor);
  uint maxGreen = COLOR_PART_GREEN(maxColor);
  uint maxBlue = COLOR_PART_BLUE(maxColor);
  CGFloat newRed = COLOR_PART_RED(newColor)/255.0f;
  CGFloat newGreen = COLOR_PART_GREEN(newColor)/255.0f;
  CGFloat newBlue = COLOR_PART_BLUE(newColor)/255.0f;
  
  NSInteger rawWidth = CGImageGetWidth(imageRef);
  NSInteger rawHeight = CGImageGetHeight(imageRef);
  NSInteger rawBitsPerComponent = 8;
  NSInteger rawBytesPerPixel = 4;
  NSInteger rawBytesPerRow = rawBytesPerPixel * rawWidth;
//  CGRect rawRect = CGRectMake(0, 0, rawWidth, rawHeight);
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  UInt8 *rawImage = (UInt8 *)malloc(rawHeight * rawWidth * rawBytesPerPixel);
//  CGContextRef rawContext = CGBitmapContextCreate(rawImage,
//                                                  rawWidth,
//                                                  rawHeight,
//                                                  rawBitsPerComponent,
//                                                  rawBytesPerRow,
//                                                  colorSpace,
//                                                  kCGImageAlphaPremultipliedLast);
  
  CGContextRef context = nil;
  
  if (alpha) {
    context = CGBitmapContextCreate(rawImage,
                                    rawWidth,
                                    rawHeight,
                                    rawBitsPerComponent,
                                    rawBytesPerRow,
                                    colorSpace,
                                    kCGImageAlphaPremultipliedLast);
    //CGBitmapContextCreate(nil, width, height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
    CGContextSetRGBFillColor(context, newRed, newGreen, newBlue, alpha);
    CGContextFillRect(context, bounds);
  }
  const CGFloat maskingColors[6] = {minRed, maxRed, minGreen, maxGreen, minBlue, maxBlue};
  CGImageRef maskedImageRef = CGImageCreateWithMaskingColors(imageRef, maskingColors);
  if (!maskedImageRef) {
    CGContextRelease(context);
    context = nil;
    return nil;
  }
  if (alpha) CGContextDrawImage(context, bounds, maskedImageRef);
  CGImageRef newImageRef = (alpha)?CGBitmapContextCreateImage(context):maskedImageRef;
  if (context) CGContextRelease(context);
  
  UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
  if (newImageRef != maskedImageRef) CGImageRelease(maskedImageRef);
  CGImageRelease(newImageRef);
  return newImage;
}

typedef struct RGBA {
  UInt8 red;
  UInt8 green;
  UInt8 blue;
  UInt8 alpha;
} RGBA;

- (UIImage *) flattenGrayscaleImage {
  
  // Create image rectangle with current image width/height
  CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
  
  int width = imageRect.size.width;
  int height = imageRect.size.height;
  
  uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
  
  // clear the pixels so any transparency is preserved
  memset(pixels, 0, width * height * sizeof(uint32_t));
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  
  // create a context with RGBA pixels
  CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                               kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
  
  // paint the bitmap to our context which will fill in the pixels array
  CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
  
  for ( int y = 0; y < height; y++ )
  {
    for ( int x = 0; x < width; x++ )
    {
      uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
      
      if ( true )
      {
        if ( rgbaPixel[0] != 0 )
          rgbaPixel[0] = 255;
      }
      // set pixels to black
      rgbaPixel[1] = 0;       // R
      rgbaPixel[2] = 0;       // G
      rgbaPixel[3] = 0;       // B
    }
  }
  
  // create a new CGImageRef from our context with the modified pixels
  CGImageRef image = CGBitmapContextCreateImage(context);
  
  // we're done with the context, color space, and pixels
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);
  free(pixels);
  
  UIImage *outputImage2 = [UIImage imageWithCGImage:image];
  CGImageRelease(image);

  return outputImage2;
  
  //  return image;
  
//  
//  // First step, using RGBA (because I know it works and does not harm, just writes/consumes twice the amount of memory)
//  CGImageRef imageRef = self.CGImage;
//  NSInteger rawWidth = CGImageGetWidth(imageRef);
//  NSInteger rawHeight = CGImageGetHeight(imageRef);
//  NSInteger rawBitsPerComponent =  CGImageGetBitsPerComponent(imageRef);
//  NSInteger rawBytesPerPixel = CGImageGetBytesPerRow(imageRef);
//  NSInteger rawBytesPerRow = CGImageGetBytesPerRow(imageRef);
//  CGRect rawRect = CGRectMake(0, 0, rawWidth, rawHeight);
//  
//  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//  UInt8 *rawImage = (UInt8 *)malloc(rawHeight * rawWidth * rawBytesPerPixel);
//  CGContextRef rawContext = CGBitmapContextCreate(rawImage,
//                                                  rawWidth,
//                                                  rawHeight,
//                                                  rawBitsPerComponent,
//                                                  rawBytesPerRow,
//                                                  colorSpace,
//                                                  kCGImageAlphaPremultipliedLast);
//  CGColorSpaceRelease(colorSpace);
//  
//  // At this point, rawContext is ready for drawing, everything drawn will be in rawImage's byte array.
//  CGContextDrawImage(rawContext, rawRect, imageRef);
//  
//  // Second step, crawl the byte array and do the evil work:
//  for (NSInteger y = 0; y < rawHeight; ++y) {
//    for (NSInteger x = 0; x < rawWidth; ++x) {
//      UInt8 *address = rawImage + x * rawBytesPerPixel + y * rawBytesPerRow;
//      RGBA *pixel = (RGBA *)address;
//      // If it is a grey input image, it does not matter what RGB channel to use - they shall all be the same
//      pixel->red = 0;
//      pixel->green = 0;
//      pixel->blue = 0;
//      
//      if (pixel->alpha != UINT8_MAX) {
//        pixel->alpha = 0;
//      }
//      // I am still not sure if this is the transformation you are searching for, but it may give you the idea.
//    }
//  }
//  
//  // Third: rawContext is ready, transformation is done. Get the image out of it
//  CGImageRef outputImage1 = CGBitmapContextCreateImage(rawContext);
//  UIImage *outputImage2 = [UIImage imageWithCGImage:outputImage1];
//  CGImageRelease(outputImage1);
//  
//  return outputImage2;
}

@end
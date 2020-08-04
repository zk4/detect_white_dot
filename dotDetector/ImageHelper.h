/*
 * The MIT License
 *
 * Copyright (c) 2011 Paul Solt, PaulSolt@gmail.com
 * modified by zk
 * https://github.com/PaulSolt/UIImage-Conversion/blob/master/MITLicense.txt
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageHelper : NSObject {
    
}

/** Converts a UIImage to RGBA8 bitmap.
 @param image - a UIImage to be converted
 @return a RGBA8 bitmap, or NULL if any memory allocation issues. Cleanup memory with free() when done.
 */
+ (unsigned char *) convertUIImageToBitmapRGBA8:(UIImage *)image;

/** A helper routine used to convert a RGBA8 to UIImage
 @return a new context that is owned by the caller
 */
+ (CGContextRef) newBitmapRGBA8ContextFromImage:(CGImageRef)image;


/** Converts a RGBA8 bitmap to a UIImage.
 @param buffer - the RGBA8 unsigned char * bitmap
 @param width - the number of pixels wide
 @param height - the number of pixels tall
 @return a UIImage that is autoreleased or nil if memory allocation issues
 */
+ (UIImage *) convertBitmapRGBA8ToUIImage:(unsigned char *)buffer
    withWidth:(int)width
    withHeight:(int)height;

+ (UIImage *)convertImageToGrayScale:(UIImage *)image;

+ (void)  printRGBA:(const unsigned char*) array width:(int) width height:(int)height;

+ (UIImage*)drawRectangleOnImage:(UIImage*)image where:(NSMutableArray*) rects ;

+ (NSMutableArray *) detectDots:(const unsigned char*) array width:(int) width height:(int)height isWhiteThreadhold:(float) whiteThreash  boundingX:(int)bx boundingY:(int)by fetchOnlyWhitest:(BOOL)whitest strideFast:(BOOL) sf;

+ (NSMutableArray *) detectDots:(UIImage*) image isWhiteThreadhold:(float) whiteThreash   boundingX:(int)bx boundingY:(int)by fetchOnlyWhitest:(BOOL)whitest strideFast:(BOOL) sf;

@end

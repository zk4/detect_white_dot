/*
 * The MIT License
 *
 * Copyright (c) 2011 Paul Solt, PaulSolt@gmail.com
 * modified by zk
 * https://github.com/PaulSolt/UIImage-Conversion/blob/master/MITLicense.txt
 *
 */

#import "ImageHelper.h"


@implementation ImageHelper


+ (unsigned char *) convertUIImageToBitmapRGBA8:(UIImage *) image {
    
    CGImageRef imageRef = image.CGImage;
    
    // Create a bitmap context to draw the uiimage into
    CGContextRef context = [self newBitmapRGBA8ContextFromImage:imageRef];
    
    if(!context) {
        return NULL;
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // Draw image into the context to get the raw image data
    CGContextDrawImage(context, rect, imageRef);
    
    // Get a pointer to the data
    unsigned char *bitmapData = (unsigned char *)CGBitmapContextGetData(context);
    
    // Copy the data and release the memory (return memory allocated with new)
    size_t bytesPerRow = CGBitmapContextGetBytesPerRow(context);
    size_t bufferLength = bytesPerRow * height;
    
    unsigned char *newBitmap = NULL;
    
    if(bitmapData) {
        newBitmap = (unsigned char *)malloc(sizeof(unsigned char) * bytesPerRow * height);
        
        if(newBitmap) {    // Copy the data
            for(int i = 0; i < bufferLength; ++i) {
                newBitmap[i] = bitmapData[i];
            }
        }
        
        free(bitmapData);
        
    } else {
        NSLog(@"Error getting bitmap pixel data\n");
    }
    
    CGContextRelease(context);
    
    return newBitmap;
}

+ (CGContextRef) newBitmapRGBA8ContextFromImage:(CGImageRef) image {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    uint32_t *bitmapData;
    
    size_t bitsPerPixel = 32;
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = bitsPerPixel / bitsPerComponent;
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    size_t bytesPerRow = width * bytesPerPixel;
    size_t bufferLength = bytesPerRow * height;
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if(!colorSpace) {
        NSLog(@"Error allocating color space RGB\n");
        return NULL;
    }
    
    // Allocate memory for image data
    bitmapData = (uint32_t *)malloc(bufferLength);
    
    if(!bitmapData) {
        NSLog(@"Error allocating memory for bitmap\n");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    //Create bitmap context
    
    context = CGBitmapContextCreate(bitmapData,
            width,
            height,
            bitsPerComponent,
            bytesPerRow,
            colorSpace,
            kCGImageAlphaPremultipliedLast);    // RGBA
    if(!context) {
        free(bitmapData);
        NSLog(@"Bitmap context not created");
    }
    
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

+ (UIImage *) convertBitmapRGBA8ToUIImage:(unsigned char *) buffer
        withWidth:(int) width
       withHeight:(int) height {
    
    
    size_t bufferLength = width * height * 4;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
    size_t bitsPerComponent = 8;
    size_t bitsPerPixel = 32;
    size_t bytesPerRow = 4 * width;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    if(colorSpaceRef == NULL) {
        NSLog(@"Error allocating color space");
        CGDataProviderRelease(provider);
        return nil;
    }
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    CGImageRef iref = CGImageCreate(width,
                height,
                bitsPerComponent,
                bitsPerPixel,
                bytesPerRow,
                colorSpaceRef,
                bitmapInfo,
                provider,    // data provider
                NULL,        // decode
                YES,            // should interpolate
                renderingIntent);
        
    uint32_t* pixels = (uint32_t*)malloc(bufferLength);
    
    if(pixels == NULL) {
        NSLog(@"Error: Memory not allocated for bitmap");
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(colorSpaceRef);
        CGImageRelease(iref);
        return nil;
    }
    
    CGContextRef context = CGBitmapContextCreate(pixels,
                 width,
                 height,
                 bitsPerComponent,
                 bytesPerRow,
                 colorSpaceRef,
                 bitmapInfo);
    
    if(context == NULL) {
        NSLog(@"Error context not created");
        free(pixels);
    }
    
    UIImage *image = nil;
    if(context) {
        
        CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), iref);
        
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        
        // Support both iPad 3.2 and iPhone 4 Retina displays with the correct scale
        if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
            float scale = [[UIScreen mainScreen] scale];
            image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
        } else {
            image = [UIImage imageWithCGImage:imageRef];
        }
        
        CGImageRelease(imageRef);
        CGContextRelease(context);
    }
    
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(iref);
    CGDataProviderRelease(provider);
    
    if(pixels) {
        free(pixels);
    }
    return image;
}

+ (UIImage *)convertImageToGrayScale:(UIImage *)image {


    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);

    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();

    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);

    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);

    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);

    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];

    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);

    // Return the new grayscale image
    return newImage;
}
+ (UIImage*)drawRectangleOnImage:(UIImage*)image where:(NSMutableArray*) rects  {
    CGSize imageSize = image.size;
    CGFloat scale = 0;

    UIGraphicsBeginImageContextWithOptions(imageSize, false, scale);

    [image drawAtPoint:CGPointMake(0, 0)];
  
    [UIColor.redColor setStroke];
    for(int i = 0 ;i < rects.count; i++)
        UIRectFrame([[rects objectAtIndex:i] CGRectValue]);


    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (void)  printRGBA:(const unsigned char*) array width:(int) width height:(int)height{
    for(int y = 0; y< height; y++){
     for (int x=0; x<width; x++){
             int  point = x*4+y;        NSLog(@"R:%d,G:%d,B:%d,A:%d",array[point],array[point+1],array[point+2],array[point+3]);
         }
     }
}

+ (NSMutableArray *) detectDots:(UIImage*) image whiteThresh:(float) whiteThresh  boundingX:(int)bx boundingY:(int)by fetchOnlyWhitest:(BOOL)whitest strideFast:(BOOL) sf{
    const unsigned char* bytes=  [ImageHelper convertUIImageToBitmapRGBA8:image];

    return    [ImageHelper detectDots:bytes width:image.size.width height:image.size.height whiteThresh:whiteThresh  boundingX:bx  boundingY:by fetchOnlyWhitest:whitest strideFast:sf];

}

+ (NSMutableArray *) detectDots:(const unsigned char*) array width:(int) width height:(int)height whiteThresh:(float) whiteThresh  boundingX:(int)bx boundingY:(int)by fetchOnlyWhitest:(BOOL)whitest strideFast:(BOOL) sf{
    float maxavg = 0.f;
    NSMutableArray * nsa =  [[NSMutableArray alloc]init];
    CGRect ret = CGRectMake(-1,-1,0,0);
 
    for(int y = 0; y< height-by+1; y+=(sf?by:1)){
        for (int x = 0; x< width-bx+1; x+=(sf?bx:1)){
             float ava = 0 ;
             int count = 0;
             for (int iy = 0;iy < by; iy++){
                 if (y+iy >= height)
                     break;
                 for(int ix = 0; ix < bx; ix++){
                     if (x+ix >= width)
                         break;
                     int  point = (x+ix+(y+iy)*width)*4;
                     float r = array[point]/255.0;
                     float g = array[point+1]/255.0;
                     float b = array[point+2]/255.0;
//                     float a =array[point+3]/255.0;
                     ava +=(r+g+b)/3.0f;
                     count ++;
                 }
             }
             ava = ava / (count*1.0f);
             if(ava >= whiteThresh){
                 if(ava>= maxavg){
                    maxavg =ava;
                    ret = CGRectMake(x, y, bx, by);
                     if(!whitest)
                         [nsa addObject:[NSValue valueWithCGRect:ret]];
                    NSLog(@"%d,%d, ava %f, probably iswhite",x,y, ava);
                 }

             }
         }
    }
  if(whitest)
    [nsa addObject:[NSValue valueWithCGRect:ret]];
  return nsa;
}
 

@end

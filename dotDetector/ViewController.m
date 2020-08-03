//
//  ViewController.m
//  dotDetector
//
//  Created by zk on 2020/8/3.
//  Copyright © 2020 zk. All rights reserved.
//

#import "ViewController.h"
#import "ImageHelper.h"




@interface ViewController ()

@end

typedef struct
{
    int x;
    int y;
} DotPos ;

typedef struct
{
    uint8_t r;
    uint8_t g;
    uint8_t b;
} RGB;
RGB MakeRGB(int r,int g ,int b){
    RGB rgb;
    rgb.r=r;
    rgb.g=g;
    rgb.b=b;
    return rgb;
}

@implementation ViewController
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

- (void)  printRGBA:(const unsigned char*) array width:(int) width height:(int)height{
    for(int y = 0; y< height; y++){
     for (int x=0; x<width; x++){
             int  point = x*4+y;        NSLog(@"R:%d,G:%d,B:%d,A:%d",array[point],array[point+1],array[point+2],array[point+3]);
         }
     }
}
- (NSMutableArray *) dectectWhiteDots:(const unsigned char*) array width:(int) width height:(int)height isWhiteThreadhold:(float) whiteThreash  boundingX:(int)bx boundingY:(int)by fetchOnlyWhitest:(BOOL)whitest{
    float maxavg = 0.f;
    NSMutableArray * nsa =  [[NSMutableArray alloc]init];
    CGRect ret = CGRectMake(-1,-1,0,0);
     for(int y = 0; y< height-by+1; y++){
         for (int x = 0; x< width-bx+1; x++){
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
                     float a =array[point+3]/255.0;
                     ava +=(r+g+b)/3.0f;
                     count ++;
                 }
             }
             ava = ava / (count*1.0f);
             if(ava >= whiteThreash){
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
 - (UIImage *)convertImageToGrayScale:(UIImage *)image {


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
 
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
      UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 300, 300)];
    
    UIImage * image =  [UIImage imageNamed:@"a.png"];
//    image = [self convertImageToGrayScale:image];
    const unsigned char* bytes=  [ImageHelper convertUIImageToBitmapRGBA8:image];

    NSMutableArray * rects = [self dectectWhiteDots:bytes width:image.size.width height:image.size.height isWhiteThreadhold:.7f  boundingX:10  boundingY:10 fetchOnlyWhitest:YES];
    
      UIImage * newimg= [ViewController drawRectangleOnImage:image where:rects];

    imageView.image  = newimg;
    [self.view addSubview:imageView];
   
 
    
}


@end

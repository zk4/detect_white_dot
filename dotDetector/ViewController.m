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
 
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
      UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 300, 300)];
    
    UIImage * image =  [UIImage imageNamed:@"a.png"];
//    image = [self convertImageToGrayScale:image];
    const unsigned char* bytes=  [ImageHelper convertUIImageToBitmapRGBA8:image];

    NSMutableArray * rects = [ImageHelper dectectWhiteDots:bytes width:image.size.width height:image.size.height isWhiteThreadhold:.7f  boundingX:10  boundingY:10 fetchOnlyWhitest:YES];
    
      UIImage * newimg= [ImageHelper drawRectangleOnImage:image where:rects];

    imageView.image  = newimg;
    [self.view addSubview:imageView];
   
}


@end

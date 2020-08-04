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

@implementation ViewController
 
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
      UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 300, 300)];
    
    UIImage * image =  [UIImage imageNamed:@"a.png"];

    NSMutableArray * rects = [ImageHelper detectDots:image isWhiteThreadhold:.5f  boundingX:10  boundingY:10 fetchOnlyWhitest:YES strideFast:YES];
   
    UIImage * newimg= [ImageHelper drawRectangleOnImage:image where:rects];

    imageView.image  = newimg;
    [self.view addSubview:imageView];
   
}


@end

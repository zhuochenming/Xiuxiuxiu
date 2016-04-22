//
//  ViewController.m
//  XiuAnimation
//
//  Created by 7_______。 on 16/2/15.
//  Copyright © 2016年 7_______。. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "GCDTimerManager.h"
#import "RedGetCView.h"
#import "RedDisGetCView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height
#define ADAPT_WIDTH(i) SCREEN_WIDTH*((i)/750.f)
#define ADAPT_HEIGHT(i) SCREEN_HEIGHT*((i)/1335.f)

@interface ViewController ()

@property (nonatomic, strong) CADisplayLink *disPlayLink;

@property (nonatomic, strong) AVAudioPlayer *myplayer;

@property (nonatomic, assign) BOOL isFirst;

@property (nonatomic, strong) RedDisGetCView *disGetView;//没有咻中

@property (nonatomic, strong) RedGetCView *getView;//咻中红包

@end

@implementation ViewController

- (CADisplayLink *)disPlayLink {
    if (_disPlayLink == nil) {
        _disPlayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(click)];
        _disPlayLink.frameInterval = 40;
    }
    return _disPlayLink;
}

- (AVAudioPlayer *)myplayer {
    if (_myplayer == nil) {
        NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"xiuVoice" ofType:@"wav"];
        NSData *voiceData = [NSData dataWithContentsOfFile:audioPath];
        
        _myplayer = [[AVAudioPlayer alloc] initWithData:voiceData error:nil];
    }
    return _myplayer;
}

- (RedDisGetCView *)disGetView {
    if (_disGetView == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RedDisGetCView" owner:nil options:nil];
        _disGetView = [nib firstObject];
        _disGetView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT + 10);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDisGetView)];
        [_disGetView addGestureRecognizer:tap];
        
    }
    return _disGetView;
}

- (RedGetCView *)getView {
    if (_getView == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RedGetCView" owner:nil options:nil];
        _getView = [nib firstObject];
        _getView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT + 10);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissGetView)];
        [_getView addGestureRecognizer:tap];
    }
    return _getView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageVBack = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    imageVBack.image = [UIImage imageNamed:@"hb_c"];
    [self.view addSubview:imageVBack];
    
     UIImageView *imageVXiu = [[UIImageView alloc] initWithFrame: CGRectMake(SCREEN_WIDTH/2 - ADAPT_HEIGHT(103), ADAPT_HEIGHT(705), ADAPT_HEIGHT(206), ADAPT_HEIGHT(206))];
    imageVXiu.image = [UIImage imageNamed:@"hb_d"];
    [self.view addSubview:imageVXiu];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self.view];
    
    CGFloat x = SCREEN_WIDTH / 2 - ADAPT_HEIGHT(103);
    CGFloat y = ADAPT_HEIGHT(705);
    CGFloat xw =  SCREEN_WIDTH / 2 + ADAPT_HEIGHT(103);
    CGFloat yh = ADAPT_HEIGHT(705) + ADAPT_HEIGHT(206);
    
    if (point.x > x && point.x < xw && point.y > y && point.y < yh) {
        //十分之一的概率 得到红包
        int luckNumber = arc4random() % 10;
        if (luckNumber == 7) {
            [self.view addSubview:self.getView];
        } else if (luckNumber == 5) {
            [self.view addSubview:self.disGetView];
        }
        
        //开始xiu动画
        [self.disPlayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.isFirst = YES;
        
        dispatch_queue_t quene = dispatch_queue_create("xiaoba", DISPATCH_QUEUE_SERIAL);
        dispatch_async(quene, ^{
            if (![self.myplayer isPlaying]) {
                [self.myplayer play];
            }
        });
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self cancle];
}

#pragma mark 动画
- (void)click {
    if (self.isFirst) {
        self.isFirst = NO;
        CALayer *layer = [[CALayer alloc] init];
        layer.cornerRadius = ADAPT_HEIGHT(320);
        layer.frame = CGRectMake(0, 0, layer.cornerRadius * 2 , layer.cornerRadius * 2);
        layer.borderWidth = 5;
        layer.position = CGPointMake([[UIScreen mainScreen]bounds].size.width / 2, ADAPT_HEIGHT(705) + ADAPT_HEIGHT(103));
        UIColor *color = [UIColor colorWithRed:255 / 255.0 green:255 / 255.0 blue:255 / 255.0 alpha:1];
        
        layer.borderColor =color.CGColor;
        //点击后扇形的边
        [self.view.layer addSublayer:layer];
        
        CAMediaTimingFunction *defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        
        CAAnimationGroup *animaTionGroup = [CAAnimationGroup animation];
        animaTionGroup.delegate = self;
        animaTionGroup.duration = 2;
        animaTionGroup.removedOnCompletion = YES;
        animaTionGroup.timingFunction = defaultCurve;
 
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
        scaleAnimation.fromValue = @0.0;
        scaleAnimation.toValue = @1;
        scaleAnimation.duration = 2;
  
        CAKeyframeAnimation *opencityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opencityAnimation.duration = 2;
        opencityAnimation.values = @[@0.8,@0.4,@0.0];
        opencityAnimation.keyTimes = @[@0,@0.5,@1];
        opencityAnimation.removedOnCompletion = YES;
  
        NSArray *animations = @[scaleAnimation,opencityAnimation];
        
        animaTionGroup.animations = animations;
        [layer addAnimation:animaTionGroup forKey:@"groupAnnimation"];
        
        [self performSelector:@selector(removeLayer:) withObject:layer afterDelay:1.5f];
    }
}

- (void)removeLayer:(CALayer *)layer {
    [layer removeFromSuperlayer];
    [layer removeAnimationForKey:@"groupAnnimation"];
}

- (void)cancle {
    self.isFirst = NO;
    [_disPlayLink invalidate];
    _disPlayLink = nil;
    [self.view.layer removeAllAnimations];
}

- (void)dismissGetView {
    [self.getView removeFromSuperview];
}

- (void)dismissDisGetView {
    [self.disGetView removeFromSuperview];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden =YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end

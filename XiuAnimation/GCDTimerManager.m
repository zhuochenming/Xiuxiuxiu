//
//  GCDTimerManager.m
//  GIFHUD
//
//  Created by 酌晨茗 on 1/12/16.
//  Copyright (c) 2016 酌晨茗. All rights reserved.
//

#import "GCDTimerManager.h"

@interface GCDTimerManager()

@property (nonatomic, strong) NSMutableDictionary *timerContainer;

@property (nonatomic, strong) NSMutableDictionary *actionBlockCache;

@end

@implementation GCDTimerManager

#pragma mark - 初始化
+ (GCDTimerManager *)sharedInstance {
    static GCDTimerManager *_gcdTimerManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        _gcdTimerManager = [[GCDTimerManager alloc] init];
    });
    
    return _gcdTimerManager;
}

#pragma mark - 类方法
+ (void)scheduledDispatchTimerWithName:(NSString *)timerName
                          timeInterval:(CGFloat)interval
                                 queue:(dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                          actionOption:(LastJobManager)option
                                action:(dispatch_block_t)action {
    [[self sharedInstance] scheduledDispatchTimerWithName:timerName timeInterval:interval queue:queue repeats:repeats actionOption:option action:action];
}

+ (void)cancelTimerWithName:(NSString *)timerName {
    [[self sharedInstance] cancelTimerWithName:timerName];
}

+ (void)cancelAllTimer {
    [[self sharedInstance] cancelAllTimer];
}

#pragma mark - 实例方法
- (void)scheduledDispatchTimerWithName:(NSString *)timerName
                          timeInterval:(CGFloat)interval
                                 queue:(dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                          actionOption:(LastJobManager)option
                                action:(dispatch_block_t)action {
    if (nil == timerName) {
        return;
    }

    if (nil == queue) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }

    dispatch_source_t timer = [self.timerContainer objectForKey:timerName];
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_resume(timer);
        [self.timerContainer setObject:timer forKey:timerName];
    }
    
    /* timer精度为0.1秒 */
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    
    __weak typeof(self) weakSelf = self;
    
    switch (option) {
            
        case LastJobManagerDisabled:
        {
            /* 移除之前的action */
            [weakSelf removeActionCacheForTimer:timerName];
            
            dispatch_source_set_event_handler(timer, ^{
                action();
                
                if (!repeats) {
                    [weakSelf cancelTimerWithName:timerName];
                }
            });
        }
            break;
            
        case LastJobManagerJoinin:
        {
            /* cache本次的action */
            [self cacheAction:action forTimer:timerName];
            
            dispatch_source_set_event_handler(timer, ^{
                NSMutableArray *actionArray = [self.actionBlockCache objectForKey:timerName];
                [actionArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    dispatch_block_t actionBlock = obj;
                    actionBlock();
                }];
                [weakSelf removeActionCacheForTimer:timerName];
                
                if (!repeats) {
                    [weakSelf cancelTimerWithName:timerName];
                }
            });
        }
            break;
    }
}

- (void)cancelTimerWithName:(NSString *)timerName {
    dispatch_source_t timer = [self.timerContainer objectForKey:timerName];
    
    if (!timer) {
        return;
    }
    
    [self.timerContainer removeObjectForKey:timerName];
    dispatch_source_cancel(timer);
    
    [self.actionBlockCache removeObjectForKey:timerName];
}

- (void)cancelAllTimer {
    // Fast Enumeration
    [self.timerContainer enumerateKeysAndObjectsUsingBlock:^(NSString *timerName, dispatch_source_t timer, BOOL *stop) {
        [self.timerContainer removeObjectForKey:timerName];
        dispatch_source_cancel(timer);
    }];
}

#pragma mark - Property
- (NSMutableDictionary *)timerContainer {
    if (!_timerContainer) {
        _timerContainer = [[NSMutableDictionary alloc] init];
    }
    return _timerContainer;
}

- (NSMutableDictionary *)actionBlockCache {
    if (!_actionBlockCache) {
        _actionBlockCache = [[NSMutableDictionary alloc] init];
    }
    return _actionBlockCache;
}

#pragma mark - Private Method
- (void)cacheAction:(dispatch_block_t)action forTimer:(NSString *)timerName {
    id actionArray = [self.actionBlockCache objectForKey:timerName];
    
    if (actionArray && [actionArray isKindOfClass:[NSMutableArray class]]) {
        [(NSMutableArray *)actionArray addObject:action];
    } else {
        NSMutableArray *array = [NSMutableArray arrayWithObject:action];
        [self.actionBlockCache setObject:array forKey:timerName];
    }
}

- (void)removeActionCacheForTimer:(NSString *)timerName {
    if (![self.actionBlockCache objectForKey:timerName]) {
         return;
    }
    [self.actionBlockCache removeObjectForKey:timerName];
}

@end

//
//  CircularLock.m
//  CirucularLock
//
//  Created by Cem Olcay on 10/06/14.
//  Copyright (c) 2014 studionord. All rights reserved.
//

#import "CircularLock.h"

@implementation CircularLock

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.radius = frame.size.height/2;
        [self.layer setCornerRadius:self.radius];
        
        self.locked = NO;
        self.circleColor = [UIColor greenColor];
        self.strokeColor = [UIColor whiteColor];
        
        self.lockedImage = [UIImage imageNamed:@"locked.png"];
        self.unlockedImage = [UIImage imageNamed:@"unlocked.png"];
        
        self.duration = 1.5;
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.imageView setImage:self.locked?self.lockedImage:self.unlockedImage];
        [self.imageView.layer setCornerRadius:self.radius];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:self.imageView];
    }
    return self;
}

- (instancetype)initWithCenter:(CGPoint)center radius:(CGFloat)r duration:(CGFloat)d strokeWidth:(CGFloat)width baseColor:(UIColor *)baseColor strokeColor:(UIColor *)strokeColor lockedImage:(UIImage *)lockedImage unlockedImage:(UIImage *)unlockedImage isLocked:(BOOL)locked didlockedCallback:(didLockedBlock)didLocked didUnlockedCallback:(didUnlockedBlock)didUnlocked {
    if ((self = [super initWithFrame:CGRectMake(center.x-r, center.y-r, r*2, r*2)])) {
        [self.layer setCornerRadius:r];
        self.locked = locked;
        
        self.radius = r;
        self.duration = d;
        self.strokeWidth = width;

        self.circleColor = baseColor;
        self.strokeColor = strokeColor;
        self.lockedImage = lockedImage;
        self.unlockedImage = unlockedImage;
        
        self.didLocked = didLocked;
        self.didUnlocked = didUnlocked;
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, r*2, r*2)];
        [self.imageView setImage:self.locked?self.lockedImage:self.unlockedImage];
        [self.imageView.layer setCornerRadius:r];
        [self.imageView.layer setMasksToBounds:YES];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.locked) {
        [self unlockAnimation];
    }
    else {
        [self lockAnimation];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self cancelAnimation];
}

- (void)cancelAnimation {
    [self.circleLayer removeFromSuperlayer];
    [self.strokeLayer removeFromSuperlayer];
    
    [UIView animateWithDuration:.3 animations:^{
        [self.imageView setAlpha:1];
    }];
    
    if (self.locked) {
        [self.imageView setImage:self.lockedImage];
    } else {
        [self.imageView setImage:self.unlockedImage];
    }
}

- (void)finishAnimation {
    self.locked = !self.locked;

    if (self.locked)
        self.didLocked ();
    else self.didUnlocked ();
    
    [self cancelAnimation];
}

- (void)initLayers {
    [UIView animateWithDuration:.2 animations:^{
        [self.imageView setAlpha:0];
    }];
    
    self.circleLayer = [CAShapeLayer layer];
    [self.circleLayer setPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2*self.radius, 2*self.radius) cornerRadius:self.radius] CGPath]];
    [self.circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    [self.circleLayer setStrokeColor:[self.circleColor CGColor]];
    [self.circleLayer setLineWidth:1];
    [self.layer addSublayer:self.circleLayer];
    
    self.strokeLayer = [CAShapeLayer layer];
    [self.strokeLayer setPath:self.circleLayer.path];
    [self.strokeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [self.strokeLayer setStrokeColor:[self.strokeColor CGColor]];
    [self.strokeLayer setLineWidth:self.strokeWidth];
    [self.strokeLayer setLineCap:kCALineCapRound];
    [self.layer addSublayer:self.strokeLayer];
}

- (void)lockAnimation {
    [self initLayers];
    
    CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    [strokeAnimation setDelegate:self];
    [strokeAnimation setDuration:self.duration];
    [strokeAnimation setRepeatCount:1];
    [strokeAnimation setFromValue:@0];
    [strokeAnimation setToValue:@1];
    [self.strokeLayer addAnimation:strokeAnimation forKey:@"lockAnimation"];
}

- (void)unlockAnimation {
    [self initLayers];
    
    CABasicAnimation *strokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    [strokeAnimation setDelegate:self];
    [strokeAnimation setDuration:self.duration];
    [strokeAnimation setRepeatCount:1];
    [strokeAnimation setFromValue:@0];
    [strokeAnimation setToValue:@1];
    [self.strokeLayer addAnimation:strokeAnimation forKey:@"unlockAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag)
        [self finishAnimation];
    else [self cancelAnimation];
}

@end
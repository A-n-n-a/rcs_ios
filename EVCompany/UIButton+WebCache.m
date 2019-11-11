/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIButton+WebCache.h"
#import "SDWebImageManager.h"

@implementation UIButton (WebCache)

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url withSpinner:(BOOL)spinnerNeeded{
    for (UIView *aView in [self subviews]) {
        if ([aView isKindOfClass:[UIActivityIndicatorView class]]) {
            [(UIActivityIndicatorView*)aView stopAnimating];
            [aView removeFromSuperview];
        }
    }
    if (spinnerNeeded) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.alpha = 1.0;
        activityIndicator.hidesWhenStopped = NO;
        [self addSubview:activityIndicator];
        activityIndicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [activityIndicator startAnimating];
        
        
    }
    [self setImageWithURL:url placeholderImage:nil options:0];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    
    [self setImageWithURL:url placeholderImage:placeholder options:0];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    [self setImage:placeholder forState:UIControlStateNormal];
    [self setImage:placeholder forState:UIControlStateSelected];
    [self setImage:placeholder forState:UIControlStateHighlighted];


    if (url)
    {
        [manager downloadWithURL:url delegate:self options:options];
    }
}

#if NS_BLOCKS_AVAILABLE
- (void)setImageWithURL:(NSURL *)url success:(void (^)(UIImage *image))success failure:(void (^)(NSError *error))failure;
{
    [self setImageWithURL:url placeholderImage:nil success:success failure:failure];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder success:(void (^)(UIImage *image))success failure:(void (^)(NSError *error))failure;
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 success:success failure:failure];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options success:(void (^)(UIImage *image))success failure:(void (^)(NSError *error))failure;
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    [self setImage:placeholder forState:UIControlStateNormal];
    [self setImage:placeholder forState:UIControlStateSelected];
    [self setImage:placeholder forState:UIControlStateHighlighted];

    if (url)
    {
        [manager downloadWithURL:url delegate:self options:options success:success failure:failure];
    }
}
#endif

- (void)setBackgroundImageWithURL:(NSURL *)url 
{
    [self setBackgroundImageWithURL:url placeholderImage:nil];
}

- (void)setBackgroundImageWithURL:(NSURL *)url withSpinner:(BOOL)spinnerNeeded
{
    for (UIView *aView in [self subviews]) {
        if ([aView isKindOfClass:[UIActivityIndicatorView class]]) {
            [(UIActivityIndicatorView*)aView stopAnimating];
            [aView removeFromSuperview];
        }
        
    }
    if (spinnerNeeded) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.alpha = 1.0;
        activityIndicator.hidesWhenStopped = NO;
        [self addSubview:activityIndicator];
        activityIndicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [activityIndicator startAnimating];
        
        
    }
    [self setBackgroundImageWithURL:url placeholderImage:nil];
}

- (void)setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setBackgroundImageWithURL:url placeholderImage:placeholder options:0];
}

- (void)setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    [self setBackgroundImage:placeholder forState:UIControlStateNormal];
    [self setBackgroundImage:placeholder forState:UIControlStateSelected];
    [self setBackgroundImage:placeholder forState:UIControlStateHighlighted];

    if (url)
    {
        NSDictionary *info = [NSDictionary dictionaryWithObject:@"background" forKey:@"type"];
        [manager downloadWithURL:url delegate:self options:options userInfo:info];
    }
}

#if NS_BLOCKS_AVAILABLE
- (void)setBackgroundImageWithURL:(NSURL *)url success:(void (^)(UIImage *image))success failure:(void (^)(NSError *error))failure;
{
    [self setBackgroundImageWithURL:url placeholderImage:nil success:success failure:failure];
}

- (void)setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder success:(void (^)(UIImage *image))success failure:(void (^)(NSError *error))failure;
{
    [self setBackgroundImageWithURL:url placeholderImage:placeholder options:0 success:success failure:failure];
}

- (void)setBackgroundImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options success:(void (^)(UIImage *image))success failure:(void (^)(NSError *error))failure;
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    [self setBackgroundImage:placeholder forState:UIControlStateNormal];
    [self setBackgroundImage:placeholder forState:UIControlStateSelected];
    [self setBackgroundImage:placeholder forState:UIControlStateHighlighted];

    if (url)
    {
        NSDictionary *info = [NSDictionary dictionaryWithObject:@"background" forKey:@"type"];
        [manager downloadWithURL:url delegate:self options:options userInfo:info success:success failure:failure];
    }
}
#endif


- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didProgressWithPartialImage:(UIImage *)image forURL:(NSURL *)url userInfo:(NSDictionary *)info
{
    
    if ([[info valueForKey:@"type"] isEqualToString:@"background"])
    {
        [self setBackgroundImage:image forState:UIControlStateNormal];
        [self setBackgroundImage:image forState:UIControlStateSelected];
        [self setBackgroundImage:image forState:UIControlStateHighlighted];
    }
    else
    {
        [self setImage:image forState:UIControlStateNormal];
        [self setImage:image forState:UIControlStateSelected];
        [self setImage:image forState:UIControlStateHighlighted];
    }
}


- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image forURL:(NSURL *)url userInfo:(NSDictionary *)info
{
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    for (UIView *aView in [self subviews]) {
        if ([aView isKindOfClass:[UIActivityIndicatorView class]]) {
            [(UIActivityIndicatorView*)aView stopAnimating];
            [aView removeFromSuperview];
        }
        
    }
//     NSLog(@"imagesize %@  bounds %@",NSStringFromCGSize(image.size),NSStringFromCGSize(self.bounds.size));
    if ((image.size.width<self.bounds.size.width) || (image.size.height<self.bounds.size.height)){
        image = [self resizeImage:image];
    }
    [UIView transitionWithView:self duration:2.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        if ([[info valueForKey:@"type"] isEqualToString:@"background"])
        {
            [self setBackgroundImage:image forState:UIControlStateNormal];
            [self setBackgroundImage:image forState:UIControlStateSelected];
            //        [self setBackgroundImage:image forState:UIControlStateHighlighted];
        }
        else
        {
            [self setImage:image forState:UIControlStateNormal];
            [self setImage:image forState:UIControlStateSelected];
                    //        [self setImage:image forState:UIControlStateHighlighted];
        }
    } completion:nil];
    
}

//Resize image and keep aspect ratio

-(UIImage *)resizeImage:(UIImage *)image {
     int w = image.size.width;
    
    int h = image.size.height;
    
    CGImageRef imageRef = [image CGImage];
    
    int width = w, height = h;
    
    int destWidth = self.bounds.size.width;
    
    int destHeight = self.bounds.size.height;
    
    if(w < destWidth){
        
        width = destWidth;
        
        height = h*destWidth/w;
        
    } else if(h < destHeight) {
        
        height = destHeight;
        
        width = w*destHeight/h;
        
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    
    
    CGContextRef bitmap;
    
    bitmap = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);
    
    if (image.imageOrientation == UIImageOrientationLeft) {
        
        CGContextRotateCTM (bitmap, M_PI/2);
        
        CGContextTranslateCTM (bitmap, 0, -height);
        
    } else if (image.imageOrientation == UIImageOrientationRight) {
        
        CGContextRotateCTM (bitmap, -M_PI/2);
        
        CGContextTranslateCTM (bitmap, -width, 0);
        
    } else if (image.imageOrientation == UIImageOrientationUp) {
        
    } else if (image.imageOrientation == UIImageOrientationDown) {
        
        CGContextTranslateCTM (bitmap, width,height);
        
        CGContextRotateCTM (bitmap, -M_PI);
        
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageRef);
    
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    
    UIImage *result = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    
    CGImageRelease(ref);
    
    return result;
    
}

@end

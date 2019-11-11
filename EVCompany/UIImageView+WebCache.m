/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "UIColor+ColorWithHex.h"

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url withSpinner:YES];
}

- (void)setImageWithURL:(NSURL *)url withSpinner:(BOOL)spinnerNeeded{
     if (spinnerNeeded) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.alpha = 1.0;
        activityIndicator.hidesWhenStopped = NO;
         [activityIndicator setColor:[UIColor colorWithHexString:@"#CCCCCC" andAlpha:1.0]];
        [self addSubview:activityIndicator];
        activityIndicator.center = CGPointMake(CGRectGetMidX(self.bounds)-23, CGRectGetMidY(self.bounds));
        [activityIndicator startAnimating];
        

    }
    [self setImageWithURL:url placeholderImage:nil];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setImageWithURL:(NSURL *)url withHud:(BOOL)needHud{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    [hud setMode:MBProgressHUDModeAnnularDeterminate];
    [self setImageWithURL:url placeholderImage:nil options:SDWebImageProgressiveDownload];
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

    self.image = placeholder;

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

    self.image = placeholder;

    if (url)
    {
        [manager downloadWithURL:url delegate:self options:options success:success failure:failure];
    }
}
#endif

- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}
- (void)webImageManager:(SDWebImageManager *)imageManager didProgressWithPartialImage:(UIImage *)image forURL:(NSURL *)url userInfo:(NSDictionary *)info{
  
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self];
    [hud setProgress:[info[@"progress"] floatValue]];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didProgressWithPartialImage:(UIImage *)image forURL:(NSURL *)url
{
//    self.image = image;
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    [MBProgressHUD hideAllHUDsForView:self animated:YES];
    for (UIView *aView in [self subviews]) {
        if ([aView isKindOfClass:[UIActivityIndicatorView class]]) {
            [(UIActivityIndicatorView*)aView stopAnimating];
             [aView removeFromSuperview];
        }
       
    }
//    [UIView transitionWithView:self duration:2.0f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
         self.image = image;
//    } completion:nil];
   
}

@end

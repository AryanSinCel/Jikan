//
//  MangaViewController.h
//  Jikan
//
//  Created by Celestial on 29/10/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MangaViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *mangaImg;
@property (weak, nonatomic) IBOutlet UILabel *mangaTitle;
@property (weak, nonatomic) IBOutlet UITextView *mangaSynopsisLabel;

@property(strong,nonatomic) NSDictionary *mangaInfo;

@end

NS_ASSUME_NONNULL_END

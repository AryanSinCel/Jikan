//
//  AnimeView.h
//  Jikan
//
//  Created by Celestial on 15/11/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnimeView : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *animeImg;
@property (weak, nonatomic) IBOutlet UILabel *animeTitle;
@property (weak, nonatomic) IBOutlet UITextView *animeSynopsisLabel;

@property(nonatomic,strong) NSDictionary *animeInfo;
@property (weak, nonatomic) IBOutlet UIWebView *webView;


@end

NS_ASSUME_NONNULL_END

//
//  RecommendViewController.h
//  Jikan
//
//  Created by Celestial on 29/10/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecommendViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *recommendationTableView;
@property (nonatomic,strong) NSString *animeId;
@property (nonatomic,strong) NSString *mode;

@end

NS_ASSUME_NONNULL_END

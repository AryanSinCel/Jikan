//
//  MangaTableViewCell.h
//  Jikan
//
//  Created by Celestial on 28/10/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MangaTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *mangaImageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

NS_ASSUME_NONNULL_END

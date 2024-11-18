//
//  ChapterView.h
//  Jikan
//
//  Created by Celestial on 30/10/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChapterView : UITableViewController

@property (strong, nonatomic) NSString *chapterID; 
@property (strong, nonatomic) NSArray *chapterImages;
@end

NS_ASSUME_NONNULL_END

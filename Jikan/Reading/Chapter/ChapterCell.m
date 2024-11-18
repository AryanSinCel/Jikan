//
//  ChapterCell.m
//  Jikan
//
//  Created by Celestial on 30/10/24.
//

#import "ChapterCell.h"

@implementation ChapterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.chapterImg.contentMode = UIViewContentModeScaleAspectFit;
    self.chapterImg.clipsToBounds = YES; // Prevent any image overflow
    self.chapterImg.translatesAutoresizingMaskIntoConstraints = NO;

    // Remove any extra constraints to ensure height is derived from the image's aspect ratio
    [NSLayoutConstraint activateConstraints:@[
        [self.chapterImg.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.chapterImg.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
        [self.chapterImg.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
        [self.chapterImg.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor]
    ]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end

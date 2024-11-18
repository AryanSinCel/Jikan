#import "MangaViewController.h"
#import "../Anime/RecommendViewController.h"

@interface MangaViewController ()

@end

@implementation MangaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.mangaInfo) {
        NSLog(@"%@",self.mangaInfo);
        
        NSString *imageUrl = self.mangaInfo[@"images"][@"jpg"][@"large_image_url"];
        if ([imageUrl isKindOfClass:[NSNull class]] || !imageUrl) {
            imageUrl = nil;
        }
        
        // Safely set the manga title
        NSString *mangaTitle = self.mangaInfo[@"title"];
        if ([mangaTitle isKindOfClass:[NSNull class]] || !mangaTitle) {
            mangaTitle = @"Unknown Title";
        }
        self.mangaTitle.text = mangaTitle;

        NSString *synopsis = self.mangaInfo[@"synopsis"];
        if ([synopsis isKindOfClass:[NSNull class]] || !synopsis) {
            synopsis = @"No synopsis available.";
        }
        self.mangaSynopsisLabel.text = synopsis;

        if (imageUrl) {
            NSURL *url = [NSURL URLWithString:imageUrl];
            NSURLSessionDataTask *imageTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (data && !error) {
                    UIImage *image = [UIImage imageWithData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.mangaImg.image = image;
                    });
                } else {
                    NSLog(@"Error loading image: %@", error.localizedDescription);
                }
            }];
            [imageTask resume];
        } else {
            self.mangaImg.image = [UIImage imageNamed:@"placeholder"];
        }
    } else {
        // Handle case where mangaInfo is nil
        self.mangaTitle.text = @"No manga selected.";
        self.mangaSynopsisLabel.text = @"";
        self.mangaImg.image = [UIImage imageNamed:@"placeholder"];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier]isEqualToString:@"showManga"]){
        RecommendViewController *view = [segue destinationViewController];
        view.animeId = self.mangaInfo[@"mal_id"];
        view.mode = @"manga";
        
    }
    
}


@end

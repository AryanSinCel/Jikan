#import "AnimeView.h"
#import "RecommendViewController.h"

@interface AnimeView ()

@end

@implementation AnimeView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.animeInfo) {
        
        NSLog(@"%@",self.animeInfo[@"title"]);
        
//        NSLog(@"%@",self.animeInfo[@"trailer"][@"embed_url"]);
        
        NSString *imageUrl = self.animeInfo[@"images"][@"jpg"][@"large_image_url"];
        if ([imageUrl isKindOfClass:[NSNull class]] || !imageUrl) {
            imageUrl = nil;
        }
        
        // Set the anime title safely
        NSString *animeTitle = self.animeInfo[@"title"];
        if ([animeTitle isKindOfClass:[NSNull class]] || !animeTitle) {
            animeTitle = @"Unknown Title";
        }
        self.animeTitle.text = animeTitle;

        // Set the synopsis text safely
        NSString *synopsis = self.animeInfo[@"synopsis"];
        if ([synopsis isKindOfClass:[NSNull class]] || !synopsis) {
            synopsis = @"No synopsis available.";
        }
        self.animeSynopsisLabel.text = synopsis;
        
        NSString *vedioUrl = self.animeInfo[@"trailer"][@"embed_url"];
        
        NSString *vedioEmbeedCode = [NSString stringWithFormat:@"<iframe width=\"350\" height=\"200\" src=\"%@\" title=\"YouTube video player\" frameborder=\"0\" allow=\"accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share\" referrerpolicy=\"strict-origin-when-cross-origin\" allowfullscreen></iframe>",vedioUrl];
        [[self webView] loadHTMLString:vedioEmbeedCode baseURL:nil];
        
        
        if (imageUrl) {
            NSURL *url = [NSURL URLWithString:imageUrl];
            NSURLSessionDataTask *imageTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (data && !error) {
                    UIImage *image = [UIImage imageWithData:data];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.animeImg.image = image;
                    });
                } else {
                    NSLog(@"Error loading image: %@", error.localizedDescription);
                }
            }];
            [imageTask resume];
        } else {
            self.animeImg.image = [UIImage imageNamed:@"placeholder"];
        }
    } else {
        self.animeTitle.text = @"No anime selected.";
        self.animeSynopsisLabel.text = @"";
        self.animeImg.image = [UIImage imageNamed:@"placeholder"];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier]isEqualToString:@"showRecommend"]){
        RecommendViewController *view = [segue destinationViewController];
        view.animeId = self.animeInfo[@"mal_id"];
//        NSLog(@"%@",self.animeInfo[@"id"]);
//        NSLog(@"%@",self.animeInfo);
        view.mode = @"anime";
    }
    
}


@end

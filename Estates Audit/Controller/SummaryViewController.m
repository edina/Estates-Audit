//
//  SummaryViewController.m
//  Estates Audit
//
//  Created by Colin Gormley on 16/04/2015.
//  Copyright (c) 2015 Colin Gormley. All rights reserved.
//

#import "SummaryViewController.h"
#import "Photo.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AcceptsManagedContext.h"
#import "HomePageViewController.h"
#import "EmailSupportTicket.h"

@import MapKit;

@interface SummaryViewController () <MKMapViewDelegate, CLLocationManagerDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *locationDescription;
@property (weak, nonatomic) IBOutlet UITextView *problemDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation SummaryViewController


- (void)setReport:(Report *)report
{
    _report = report;
    // Try and load image as soon as possible (asynchronous) so it's there when page loads
    [self loadImageFromAssets];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.mapView setDelegate:self];
    
    // Zoom map to region and add pin
    [self setupMap];
    
    // Do any additional setup after loading the view.
    self.locationDescription.text = self.report.loc_desc;
    self.problemDescription.text = self.report.desc;
}

-(void)setupMap{
    [self.mapView setDelegate:self];
    
    NSNumber *lat = self.report.lat;
    NSNumber *lon = self.report.lon;
    
    NSLog(@"%@, %@", lat, lon);
    CLLocationCoordinate2D reportLocation = CLLocationCoordinate2DMake([lat doubleValue] ,[lon doubleValue]);
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(reportLocation, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    //add the annotation
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    
    point.coordinate = reportLocation;
    point.title = @"Report Location";
    
    [self.mapView addAnnotation:point];
}

-(void)loadImageFromAssets{
    
    NSSet *photos = self.report.photos;
    
    NSArray *photoArray = [photos allObjects];
    if ([photoArray count] > 0){
        Photo *photo = [photoArray objectAtIndex:0];
        
        NSURL *assetUrl = [NSURL URLWithString:photo.url];
        
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
        {
            ALAssetRepresentation *rep = [myasset defaultRepresentation];
            CGImageRef iref = [rep fullResolutionImage];
            if (iref) {
                UIImage *largeimage = [UIImage imageWithCGImage:iref];
                
                [self.imageView setImage:largeimage];
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror)
        {
            NSLog(@"Can't get image - %@",[myerror localizedDescription]);
        };
        
        ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:assetUrl
                       resultBlock:resultblock
                      failureBlock:failureblock];
    }

}




#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
    
    EmailSupportTicket *emailSupportTicket =
    [[EmailSupportTicket alloc] initWithSubject:@"Estates Audit Test" message:@"This is a test message" imageAttachment:[UIImage imageNamed:@"screenshot"] viewController:self];
    
    [emailSupportTicket sendSupportEmail];

    
    
    // Ensure context is saved
    [self.report.managedObjectContext save:NULL];
    
    // Need to ensure the context is not nil
    if ([segue.destinationViewController conformsToProtocol:@protocol(AcceptsManagedContext)]) {
        
        // Need to pass managedObjectContext through
        id<AcceptsManagedContext> controller = segue.destinationViewController;
        controller.managedObjectContext  = self.report.managedObjectContext;
        
        
    }
    if ([[segue identifier] isEqualToString:@"Send"])
    {
        HomePageViewController *homevc = (HomePageViewController *)segue.destinationViewController;
        UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Home" style:UIBarButtonItemStyleBordered target:self action:@selector(home:)];
        homevc.navigationItem.leftBarButtonItem=newBackButton;
    }
    
}



- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


-(void)home:(UIBarButtonItem *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

//
//  P4RCCellView.h
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 8/31/12.
//
//

@class P4RCCellView;

@protocol P4RCCellViewDelegate

- (void)didSelectCellView:(P4RCCellView *)sender;

@end


@interface P4RCCellView : UIView

@property (nonatomic, assign) NSInteger number;
@property (nonatomic, retain) UIImage *logoImage;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, assign) id<P4RCCellViewDelegate> delegate;

@end

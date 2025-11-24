//
 //  Fmp4AVPlayer.m
 //  fmp4_player
 //
 //  Created by Giáp Phan Văn on 28/10/25.
 //

#import "Fmp4AVPlayer.h"

#import <react/renderer/components/Fmp4PlayerLibSpec/ComponentDescriptors.h>
#import <react/renderer/components/Fmp4PlayerLibSpec/EventEmitters.h>
#import <react/renderer/components/Fmp4PlayerLibSpec/Props.h>
#import <react/renderer/components/Fmp4PlayerLibSpec/RCTComponentViewHelpers.h>

#import <AVFoundation/AVFoundation.h>
#import "NativeFmp4PlayerLib-Swift.h"
using namespace facebook::react;

@interface Fmp4AVPlayer () <RCTStreamViewViewProtocol>
@end

@implementation Fmp4AVPlayer {
  Fmp4AVPlayerView * _containerView;
}

-(instancetype)init
{
  if(self = [super init]) {
    _containerView = [Fmp4AVPlayerView new];
    [self addSubview:_containerView];
  }
  return self;
}

- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps
{
  const auto &oldViewProps = *std::static_pointer_cast<StreamViewProps const>(_props);
  const auto &newViewProps = *std::static_pointer_cast<StreamViewProps const>(props);
  
  
  if (oldViewProps.streamId != newViewProps.streamId) {
    NSString *id = [NSString stringWithCString:newViewProps.streamId.c_str() encoding:NSUTF8StringEncoding];
    [_containerView setStreamID:id];
  }
  [super updateProps:props oldProps:oldProps];
  
}

-(void)layoutSubviews
{
  [super layoutSubviews];
  _containerView.frame = self.bounds;
}

+ (ComponentDescriptorProvider)componentDescriptorProvider
{
  return concreteComponentDescriptorProvider<StreamViewComponentDescriptor>();
}

Class<RCTComponentViewProtocol> StreamViewCls(void)
{
  return Fmp4AVPlayer.class;
}

@end

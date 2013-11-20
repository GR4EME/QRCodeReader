//
//  ViewController.m
//  QRCodeReader
//
//  Created by Graeme Littlewood on 17/11/2013.
//  Copyright (c) 2013 Graeme Littlewood. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([self.captureDevice isLowLightBoostSupported] && [self.captureDevice lockForConfiguration:nil]) {
        self.captureDevice.automaticallyEnablesLowLightBoostWhenAvailable = YES;
        [self.captureDevice unlockForConfiguration];
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession beginConfiguration];
    
    self.captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:nil];
    [self.captureSession addInput:self.captureDeviceInput];
    
    self.captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.captureSession addOutput:self.captureMetadataOutput];
    self.captureMetadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    [self.captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    [self.captureSession commitConfiguration];
    [self.captureSession startRunning];
    
    self.captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.captureVideoPreviewLayer.frame = self.view.bounds;
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.captureVideoPreviewLayer];
    
    if (self.captureDevice.hasTorch && self.captureDevice.torchAvailable && [self.captureDevice isTorchModeSupported:AVCaptureTorchModeOn] && [self.captureDevice lockForConfiguration:nil]) {
        [self.captureDevice setTorchModeOnWithLevel:0.25 error:nil];
        [self.captureDevice unlockForConfiguration];
    }
    
    self.highlightView = [[UIView alloc] init];
    self.highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    self.highlightView.layer.borderWidth = 3;
    [self.view addSubview:self.highlightView];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.frame = CGRectMake(0, self.view.bounds.size.height - 40, self.view.bounds.size.width, 40);
    self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.textLabel.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.text = @"(none)";
    [self.view addSubview:self.textLabel];
}
    
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    __block CGRect highlightViewRect = CGRectZero;
    __block NSString *result;
    
    [metadataObjects enumerateObjectsUsingBlock:^(AVMetadataObject *metadataObject, NSUInteger idx, BOOL *stop) {
        AVMetadataMachineReadableCodeObject *readableCodeObject = (AVMetadataMachineReadableCodeObject *)[self.captureVideoPreviewLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadataObject];
        highlightViewRect = readableCodeObject.bounds;
        result = [readableCodeObject stringValue];
    }];
    
    self.highlightView.frame = highlightViewRect;
    if (result != nil) {
        self.textLabel.text = result;
    } else {
        self.textLabel.text = @"(none)";
    }
}

@end
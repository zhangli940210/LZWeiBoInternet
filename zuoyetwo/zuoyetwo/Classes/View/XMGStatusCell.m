//
//  XMGStatusCell.m
//  zuoyetwo
//
//  Created by apple on 16/3/29.
//  Copyright © 2016年 m14a.cn. All rights reserved.
//

#import "XMGStatusCell.h"
#import "XMGStatus.h"
#import "UIImageView+WebCache.h"

static NSString * const BaseURL = @"http://api.liyaogang.com/weibo/";

@interface XMGStatusCell ()

/** 图像*/
@property (nonatomic ,weak)  IBOutlet UIImageView *iconImageView;

/** 昵称*/
@property (nonatomic ,weak) IBOutlet UILabel *nameLabel;

/** vip*/
@property (nonatomic ,weak) IBOutlet UIImageView *vipImageView;

/** 正文*/
@property (nonatomic ,weak) IBOutlet UILabel *content_Label;

/** 配图*/
@property (nonatomic ,weak)  IBOutlet UIImageView *pictureImageView;

/** 配图的高度约束*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pictureHLc;

/** 配图距离底部约束*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pictureBottomLc;


@end

@implementation XMGStatusCell

- (void)setStatus:(XMGStatus *)status
{
    _status = status;
    // 占位图
    UIImage *placehoder = [UIImage imageNamed:@"placeholder"];
    // 头像URL路径
    NSString *imageIconURL = [BaseURL stringByAppendingPathComponent:status.icon];
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:imageIconURL] placeholderImage:placehoder];
    
    // 给昵称赋值
    self.nameLabel.text = status.name;
    // 判断是否是会员
    if (status.isVip) { // 是VIP
        self.vipImageView.hidden = NO;
        self.nameLabel.textColor = [UIColor orangeColor];
    } else {
        self.vipImageView.hidden = YES;
        self.nameLabel.textColor = [UIColor blackColor];
    }
    // 给正文赋值
    self.content_Label.text = status.content;
    // 判断是否有配图
    if ([status.picture isEqualToString:@""]) { // 有配图
        self.pictureHLc.constant = 0;
        self.pictureBottomLc.constant = 0;
        
    } else {
        self.pictureHLc.constant = 100;
        self.pictureBottomLc.constant = 10;
        // 配图URL路径
        NSString *pictureURL = [BaseURL stringByAppendingPathComponent:status.picture];
        
        [self.pictureImageView sd_setImageWithURL:[NSURL URLWithString:pictureURL] placeholderImage:placehoder];
    }// 判断是否有配图
    if ([status.picture isEqualToString:@""]) { // 有配图
        self.pictureHLc.constant = 0;
        self.pictureBottomLc.constant = 0;
        
    } else {
        self.pictureHLc.constant = 100;
        self.pictureBottomLc.constant = 10;
        // 配图URL路径
        NSString *pictureURL = [BaseURL stringByAppendingPathComponent:status.picture];
        
        [self.pictureImageView sd_setImageWithURL:[NSURL URLWithString:pictureURL] placeholderImage:placehoder];
    }
}


@end

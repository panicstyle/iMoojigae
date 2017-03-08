//
//  WriteArticleViewController.h
//  iGongdong
//
//  Created by Panicstyle on 10. 10. 18..
//  Copyright 2010 이니라인. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "env.h"

@interface ArticleWriteView : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, weak) IBOutlet UITextField *viewTitle;
@property (nonatomic, weak) IBOutlet UITextView *viewContent;
@property (nonatomic, weak) IBOutlet UIImageView *viewImage0;
@property (nonatomic, weak) IBOutlet UIImageView *viewImage1;
@property (nonatomic, weak) IBOutlet UIImageView *viewImage2;
@property (nonatomic, weak) IBOutlet UIImageView *viewImage3;
@property (nonatomic, weak) IBOutlet UIImageView *viewImage4;

@property (nonatomic, strong) NSNumber *m_nMode;
@property (nonatomic, strong) NSString *m_boardId;
@property (nonatomic, strong) NSString *m_boardNo;
@property (nonatomic, strong) NSString *m_strTitle;
@property (nonatomic, strong) NSString *m_strContent;
@property id target;
@property SEL selector;
@end

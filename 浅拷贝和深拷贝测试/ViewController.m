//
//  ViewController.m
//  浅拷贝和深拷贝测试
//
//  Created by 许明洋 on 2020/9/22.
//  Copyright © 2020 许明洋. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"主界面";
//    [self arrayShallowCopyTest];
//    [self nsdictionaryShallowCopyTest];
//    [self arrayDeepCopyTest];
//    [self nsDictionaryDeepTest];
    [self shallowAndDeepCopyTest];
}

- (void)arrayShallowCopyTest {
    /*
     数组浅拷贝前后的地址都是相同的
     */
    NSArray *someArray = @[@"222"];
    NSArray *shallowCopyArray = [someArray copyWithZone:nil];
    NSLog(@"someArray address : %p",someArray);
    NSLog(@"shallowCopyArray address ：%p",shallowCopyArray);
}

- (void)nsdictionaryShallowCopyTest {
    /*
     这里输出的两个地址是不同的，和上面数组对比的区别为:
     这是因为对于数组我们只是调用了它的copyWithZone方法，但是由于是不可变数组，返回了自身，所以浅拷贝前后数组的内存地址不变
     而对于字典来说，shallowCopyDict是通过alloc、init创建的，因此在拷贝前后字典的内村地址发生了变化，其实内部元素的地址是不变的。
     引用此例是为了说明，在集合对象的浅拷贝中，并非是对于自身的浅拷贝，而是对于其内部元素的浅拷贝
     */
    NSDictionary *someDictionary = @{@"11":@"22"};
    NSDictionary *shallowCopyDict = [[NSDictionary alloc] initWithDictionary:someDictionary copyItems:NO];
    NSLog(@"someDictionary address : %p",someDictionary);
    NSLog(@"shallowCopyDict address : %p",shallowCopyDict);
}

- (void)arrayDeepCopyTest {
    /*
     前面三个的打印结果和我们预想的相符合，someArray和shallowCopyArray地址相同，后面的deepCopyArray地址不同
     关键是下面的三个地址竟然也是相同的，原因在于
     集合类型的深拷贝会对每一个元素调用copyWithZone方法，这就意味着刚刚最后三行的打印是取决于该方法，在深拷贝时对于第一个元素，调用了NNString的copyWithZone方法，但是由于NSString，但是由于NSString是不可变的，对于其深拷贝创建一个新内存是没有意义的，所以我们可以猜测在NSString的copyWithZone方法中也是直接返回self的，所以浅拷贝时是直接拷贝元素地址，r而深拷贝是通过copyWithZone方法来获取元素地址，两个结果是一样的
     */
//    NSString *str = @"2222";
    /*
     将NSString变换为NSMutableString就可以看到打印的元素地址发生了变化
     */
    NSMutableString *str = [[NSMutableString alloc] initWithString:@"222"];
    NSArray *someArray = @[str];
    NSArray *shallowCopyArray = [someArray copyWithZone:nil];
    NSArray *deepCopyArray = [[NSArray alloc] initWithArray:someArray copyItems:YES];
    
    NSLog(@"someArray address: %p",someArray);
    NSLog(@"shallowCopyArray address : %p",shallowCopyArray);
    NSLog(@"deepCopyArray address : %p",deepCopyArray);
    
    NSLog(@"someArray[0] address: %p",someArray[0]);
    NSLog(@"shallowCopyArray[0] address : %p",shallowCopyArray[0]);
    NSLog(@"deepCopyArray[0] address : %p",deepCopyArray[0]);
}

- (void)nsDictionaryDeepTest {
    /*
     最初的三个的表现结果和我们想的一致 someDictionary和shallowCopyDict地址相同，deepCopyDict地址不同
     
     接下来的三个输出结果是一样的，具体原因和上面的NSarray相同
     */
//    NSDictionary *someDictionary = @{@"11":@"22"};
    /*
     更换成这种写法，前面三个的地址输出是不同的，后面三个的地址输出相同 原因是 深拷贝
     */
//    NSMutableDictionary *someDictionary = [[NSMutableDictionary alloc] initWithDictionary:@{@"11":@"22"}];
    /*
     更换成下面这种写法 前面三个的输出中，第一个和第二个输出相同，第三个输出不同
     下面三个的输出依旧相同
     */
    NSMutableDictionary *some = [NSMutableDictionary dictionary];
    [some setValue:@"22" forKey:@"11"];
    NSDictionary *someDictionary = [NSDictionary dictionaryWithDictionary:some];
    NSDictionary *shallowCopyDict = [someDictionary copyWithZone:nil];
    NSDictionary *deepCopyDict = [[NSDictionary alloc] initWithDictionary:someDictionary copyItems:YES];
    NSLog(@"someDictionary address : %p",someDictionary);
    NSLog(@"shallowCopyDict address : %p",shallowCopyDict);
    NSLog(@"deepCopyDict address : %p",deepCopyDict);
    
    NSLog(@"someDictionary first key address : %p",someDictionary[@"11"]);
    NSLog(@"shallowCopyDict first key address : %p",shallowCopyDict[@"11"]);
    NSLog(@"deepCopyDict first key address : %p",deepCopyDict[@"11"]);
}

//非集合类型的拷贝
- (void)shallowAndDeepCopyTest {
    /*
     结果是string和stringCopy的地址是相同的，stringMCopy的地址是不同的
     原因：
     可以看到，对NSString进行copy只是对其指针的拷贝，而进行mutableCopy是真正重新创建一份新的NSString对象
     之前介绍过，写定的字符串是存在于内存的常量区，因此可以看到两处地址的位置相差甚远。
     并且，前面也说到。copy方法是与NSCoping协议相关的，而mutableCopy是与NSMutableCoping协议相关的，对于NSString这样的不可变系统类来说，copy后返回自身是比较好理解的，因为NSString是不可变的，对其copy也仍然是相同的内容，因此copy后仍然是相同的内存地址，而mutableCopy表明你或许真的需要一份新的可变对象，因此对NSString进行mutableCopy后会返回一个NSMutableString对象
     */
    NSString *string = @"123";
    NSString *stringCopy = [string copy];
    NSMutableString *stringMCopy = [string mutableCopy];
    NSLog(@"string address : %p",string);
    NSLog(@"stringCopy address : %p",stringCopy);
    NSLog(@"stringMCopy address : %p",stringMCopy);
    
    /*
     结果是三者的地址都不相同，并且copy返回的是一个不可变的字符串，mutableCopy返回的是一个可变的字符串
     */
    NSMutableString *mString = [[NSMutableString alloc] initWithString:@"123"];
    NSString *copyString = [mString copy];
    NSString *mCopyString = [mString mutableCopy];
    NSLog(@"mstring address： %p",mString);
    NSLog(@"copyString address: %p",copyString);
    NSLog(@"mCopyString address: %p",mCopyString);
    NSLog(@"copyString is Mutable ? %@",[copyString isKindOfClass:NSMutableString.class] ? @"YES" : @"NO");
    NSLog(@"mCopyString is Mutable ? %@",[mCopyString isKindOfClass:NSMutableString.class] ? @"YES" : @"NO");
    
    /*
     总结：不可变对象的copy操作是指针拷贝，mutableCopy是对象拷贝，而可变对象因为实现了NSCoping协议，因此不管copy操作还是mutableCopy操作都是对象拷贝。
     */
}

@end

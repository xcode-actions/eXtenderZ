/*
Copyright 2021 happn
Copyright 2024 François Lamboley

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

#import "NSObject_WorkaroundForDoc.h"
#import "XTZCategoriesLoader.h"

#import "NSObject+Utils.h"
#import "NSObject+eXtenderZ.h"



#ifdef eXtenderZ_STATIC

@implementation XTZCategoriesLoader

+ (void)loadCategories
{
	__xtz_linkNSObjectUtilsCategory();
	__xtz_linkNSObjectExtenderzCategory();
}

@end

#endif

/*
Copyright 2019 happn
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

#ifndef __eXtenderZ_static_h__
# define __eXtenderZ_static_h__

/* Defined here _and_ in build settings.
 * We previously did not need it in the build settings,
 *  but now we do because we allow force loading the categories in the static version of the xcframework to avoid the need of -ObjC.
 * As this is not needed in the dymamic version of the xcframework, we want not to do it in it.
 * So we need the preprocessor instruction to be defined in the source files to know whether to load the categories or not,
 *  which is done with the build settings, and in eXtenderZ.h in the client code to know which quoting style to use (the define in this file).
 * As an added bonus, clients can know whether the xcframework they are using is static or dynamic using a preprocessor check.
 *
 * Note:
 * We could easily have left the force loading of the categories in the dynamic xcframework.
 * It has _no_ performance impact (it is never called!).
 * The only different AFAIK is the addition of a few symbols. */
# define eXtenderZ_STATIC
# include "eXtenderZ.h"

#endif /* __eXtenderZ_static_h__ */

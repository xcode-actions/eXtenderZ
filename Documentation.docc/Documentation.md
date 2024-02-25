# ``eXtenderZ``

Change the behavior of objects at runtime using `isa-swizzling`.

## Overview

The eXtenderZ package gives you a convenient method to create new classes on the fly containing the code you want
and change the type of the instances you want to behave differently.

## Topics

### Adding an Extender to an Object

Usually you should add extenders on objects using the two first methods here.
These two methods will raise an exception if the extender cannot be added to the object.  
The third method is the underlying method called by the two conveniences.
It is possible to call the third method directly.

- ``CHECKED_ADD_EXTENDER``
- ``HPNCheckedAddExtender``
- ``NSObject_WorkaroundForDoc/hpn_addExtender:``

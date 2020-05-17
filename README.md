Redmine Local Avatars
=====================

![Run RuboCop](https://github.com/alexandermeindl/redmine_local_avatars/workflows/Run%20RuboCop/badge.svg) ![Run Tests](https://github.com/alexandermeindl/redmine_local_avatars/workflows/Run%20Tests/badge.svg)

This plugin allows Redmine users to upload a picture to be used as an avatar
(instead of depending on images from Gravatar).

Users can set their image through the `/my/account` page.  The administrator can
also manage users' avatars through the `/users` and /groups sections.

Installation
------------

1. Place the plugin in the `plugins` directory of your Redmine
installation (or create a symlink).
2. Execute `bundle install`

Compatibility
-------------

- Redmine 4.1 is required

Authors
-------

A. Chaika wrote the original version:

* http://www.redmine.org/boards/3/topics/5365
* https://github.com/Ubik/redmine_local_avatars
* https://github.com/thorin/redmine_local_avatars Thorin
* https://github.com/alexandermeindl/redmine_local_avatars Alexander Meindl

Luca Pireddu (<pireddu@gmail.com>) at CRS4 ([http://www.crs4.it](http://www.crs4.it)),
contributed updates and improvements.


Ricardo S contributed with the webcam snapshot, crop features and other updates.

Warranty.  What warranty?
-------------------------

This plugin was written for use in an intranet with simple requirements in mind.
In particular, not much attention has been payed to security issues and there
hasn't been any thorough testing.  Use it at your own risk.  Patches are
welcome.


Implementation Notes
--------------------

Avatar images are treated as attachments to User objects with the description
'avatar'.  The AccountController is patched to provide the images, and the
UsersController, GroupsController and MyController are patched to provide mechanisms to add/delete
avatars.


License
-------

Copyright (C) 2013  Andrew Chaika, Luca Pireddu, Ricardo S

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
Street, Fifth Floor, Boston, MA  02110-1301, USA.

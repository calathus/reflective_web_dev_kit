#Reflective Web Dev Kit

## Overview ##

The goal of this project is to create a small end2end sample application using component based approch.
Dart's mirror library will be applied to several area of web application, GUI, Database Access, client/server communication.
Thus the project is called 'reflective' web dev kit.

See following blog site:
[http://dartathus.blogspot.com](http://dartathus.blogspot.com/)

###1. portable_mirror
right now, darts:mirrors library cannot be used javascript mode. So if we directly use this library, most of code cannot be run on browser.
This lib provides a portable mirror API to support (small subset of) mirror features in which dart:mirrors is not used. 
There are two implementations for this API class. one depends on static classes, and the other depends on dart:mirror. 
No code changes are required to run application on javascripts mode or Dartium mode(using Dart VM). 

###2. json_mapper
json mapping based on mirror library. this automatically map json to corresponding entity instance

###3.couchdb
dao api for couchdb based on mirror/json_mapper. this provides server side json_proxy, and client side couchdb dao library

###4. gui_component
a framework to create web application using component based design, also table/form are implemented as generic class using mirror.

###5. sample_app
This is a sample web application using these libraries.
This web application supports CRUD operation using Table and Form.

![Sample App](https://raw.github.com/calathus/reflective_web_dev_kit/master/doc/sample_app2.png)

This tool supports CRUD GUI and Data persistence through CouchDB.

In order to have this tool, you need to dfine Model class, and some top level Dart classes.

![Model class](https://raw.github.com/calathus/reflective_web_dev_kit/master/sample_app/lib/src/models.dart)

![CRUD class](https://raw.github.com/calathus/reflective_web_dev_kit/master/sample_app/web/sample_common_generic_gui.dart)

### How to run ##
0) install/run couchdb

1) run server:
in sample_app/bin folder, there is a dirt file:
SampleServer.dart

run it with Dart command-line launch

2) run client:
in sample_app/web folder, there is two html files:
sample_static_generic_gui.html
sample_dynamic_generic_gui.html

use them to launch application.


### To Do List ##
~~1) the json_mapper need to support list/map attribute~~
this was supported.

2) for json_mapper, subclass identification should be done.

3) should use annotation to allow more control over the GUI presentation for gui_components.
4) use AOP style injection for DB access/logging.
...

There are a lot of thing to refine this app.
The main goal was to have a simple sample project to evaluate the feasibility of generic/mirror based approach.
so this is not bad shape for this purpose.
eventually I will fix some of the remaining issues.


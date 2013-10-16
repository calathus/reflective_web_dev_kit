// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library piratebadge;

import 'dart:html';
import 'dart:math';

import "../../gui_component/lib/monitor_lib.dart";
import "package:gui_component/gui_component_lib.dart";

class NameBadge extends Component with Monitor {
  static const String APP = "g_namebage";
  TextInputComp textInput;
  ButtonComp button;
  RadioComp maleRadio;
  RadioComp femaleRadio;
  
  Element _div0;
  Element _initDiv0(Element e) => _div0 = e;

  @Monitored()
  String _badgename = 'Bob';
  @Monitored()
  bool _male = false;
  @Monitored()
  bool _female = true;

  String get badgename => get(const Symbol('badgename'));
  void set badgename(String v) => set(const Symbol('badgename'), v);
  
  bool get male => get(const Symbol('male'));
  void set male(bool v) => set(const Symbol('male'), v);
  
  bool get female => get(const Symbol('female'));
  void set female(bool v) => set(const Symbol('female'), v);
  
  NameBadge(Component parent): super(parent, const[APP]) {
    this.textInput = new TextInputComp(this, "Enter New Name:", String);
    this.button = new ButtonComp(this, "Generate pirate name", (e) { badgename = pirateName(); });
    this.maleRadio = new RadioComp(this, "Male", "male", _male, name:"maleOrFemale")..onClick((_, comp){ print('>> RadioComp male'); male = true; });
    this.femaleRadio = new RadioComp(this, "Female", "female", _female, name:"maleOrFemale")..onClick((_, comp){ print('>> RadioComp female'); female = true; });
    
    addSetListener(const Symbol("badgename"), (NameBadge target, String old_value, String new_value){
      textInput.value = new_value;
      _div0.text = new_value;
      print('~~badgename type ${target} old_value ${old_value}, new_value ${new_value}');
    });
    addSetListener(const Symbol("male"), (NameBadge target, bool old_value, bool new_value){
      if (old_value == new_value) {
        print('~~ no change: male type ${target} old_value ${old_value}');
        return;
      }
      if (_male && _female) {
        female = false;
      }
      print('~~male type ${target} old_value ${old_value}');
    });
    addSetListener(const Symbol("female"), (NameBadge target, bool old_value, bool new_value){
      if (old_value == new_value) {
        print('~~ no change: female type ${target} old_value ${old_value}');
        return;
      }
      if (_female && _male) {
        male = false;
      }
      print('~~female type ${target} old_value ${old_value}');
    });
  }
  String pirateName() {
    if (_female) {
      return new PirateName.female().name;
    } else {
      return new PirateName.male().name;
    }
  }
  
  Element createElement() => addSubComponents0(newElem("div"));
  
  Element update() => addSubComponents0(initElem());
  
  Element addSubComponents0(Element elm) => addListeners(
      elm
        ..nodes.add(
            new Element.div()
              ..classes.add("entry")
              ..nodes.add(textInput.element)
              ..nodes.add(button.element)
              ..nodes.add(maleRadio.element)
              ..nodes.add(femaleRadio.element))
        ..nodes.add(
            new Element.div()
              ..classes.add("outer")
              ..nodes.add(new Element.div()..classes.add('boilerplate')..text = 'Hi! My name is')
              ..nodes.add(_initDiv0(new Element.div()..classes.add('name')..text = _badgename))));
}

//library models;
class PirateName {
  
  Random indexGenerator = new Random();
  
  String _pirateName;
  
  String get name => _pirateName;
         set name(String value) => _pirateName = value;
         
  String toString() => name;

  static const List titles = const [ 'Captn', 'Mate', 'Sailor'];
  static const List maleNames = const [ 'Jack', 'Jonas', 'Billy'];
  static const List femaleNames = const [ 'Jane', 'Sue', 'Maria'];
  
  PirateName.male() {
    String title = titles[indexGenerator.nextInt(titles.length)];
    String firstName = maleNames[indexGenerator.nextInt(maleNames.length)];
    _pirateName = '$title $firstName';
  }

  PirateName.female() {
    String title = titles[indexGenerator.nextInt(titles.length)];
    String firstName = femaleNames[indexGenerator.nextInt(femaleNames.length)];
    _pirateName = '$title $firstName';
  }
  
}

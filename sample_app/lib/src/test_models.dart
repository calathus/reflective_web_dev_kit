library test_models;

class A {
  int _i = 0;
  List<B> _bs = [];
  
  A(this._i, this._bs);
  factory A.create() => new A(111, []);
  
  int get i => _i;
  void set i(int ii) { _i == ii; }
  
  List<B> get bs => _bs;
  void set bs(List<B> bs) {_bs = bs; }
}

class B {
  String _s = 'zz';
  B(this._s);
  factory B.create() => new B('ss');
  String get s => _s;
  void set s(String ss) { _s == ss; }
}

/*
class A {
  int _i = 0;
  List<B> _bs = [];
  
  int get i => _i;
  void set i(int ii) { _i == ii; }
  
  List<B> get bs => _bs;
  void set bs(List<B> bs) {_bs = bs; }
}

class B {
  String _s = 'zz';
  
  String get s => _s;
  void set s(String ss) { _s == ss; }
}
*/
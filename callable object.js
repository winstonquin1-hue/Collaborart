/**
 *
 *  Prevent function based "Role" pattern implementations[1] like "Mixin"s,
 *  "Trait"s or "Talent"s from getting instantiated by turning them into
 *  callable objects. Thus creating real objects but providing [call] and
 *  [apply] as standard call/delegation methods to them.
 *
 *  The concept will be promoted as "Applicator" in order to distinguish
 *  it from "Constructor". (Though in theirs wording both do follow the
 *  same track.)
 *
 *  Even though the implementation creates a real "callable object" that
 *  preserves a function object just as a delegate and using descriptions
 *  with a wording close to "applicator", "applicable" or "applicative",
 *  there are no connections at all to "Functor"s from a mathematical or
 *  functional programming point of view.
 *
 *  [1][http://peterseliger.blogspot.com/2014/04/the-many-talents-of-javascript.html]
 *
 */
 
 //---------------------------
//this wasn't from this originally 
// but may be of use here? maybe?
// var obj = Object.assign(Object.create(Object.getPrototypeOf(fn)), fn);}
// maybe not? 
 
 <script>
(function (Function, Object, Array) {         // module


  var
    functionPrototype = Function.prototype,


    isFunction = (function (FUNCTION_TYPE) {
      return function (type) {
        return (
             (typeof type == FUNCTION_TYPE)
          && (typeof type.call == FUNCTION_TYPE)
          && (typeof type.apply == FUNCTION_TYPE)
        );
      };
    }("function")),

    makeArray = (isFunction(Array.from) && Array.from) || (function (array_prototype_slice) {
      return function (listType) {

        return array_prototype_slice.call(listType);
      };
    }(Array.prototype.slice));


  function testCallability(type) {
    var callability = true;
    try {
      type();
    //functionPrototype.call.call(type); // merciless.
    } catch (exc) {
      callability = false;
    }
    return callability;
  }

  function isCallable(type) {
    return (type ? testCallability(type) : false);
  //return (type ? testCallability(type) : !!type);
  }


  function getSanitizedTarget(target) {
    return ((target != null) && target) || null;
  }


  function Applicator() {                     // constructor
  //this.constructor = Object;                // - just for being able falling back
    return this;                              //   to a more easy to accomplish
  }                                           //   [isApplicator] test.


  function withApplicator(protoApplicator) {  // mixin/trait implementation
    var
        callableObject = this;

    callableObject.call = function () {
      var
        args   = makeArray(arguments),
        target = getSanitizedTarget(args.shift())
      ;
      protoApplicator.apply(target, args);
    };
    callableObject.apply = function (target, args) {
      args   = makeArray(args);
      target = getSanitizedTarget(target);

      protoApplicator.apply(target, args);
    };
    callableObject.valueOf = function () {
      return protoApplicator;
    };
    callableObject.toString = function () {
      return [

        "Applicator :: ",
        protoApplicator

      ].join("");
    };

    return callableObject;
  }


  function toApplicator(protoApplicator) {    // factory
    var callableObject;
    if (isFunction(protoApplicator)) {

      callableObject = (new Applicator);
      withApplicator.call(callableObject, protoApplicator);
    }
  //return callableObject;
    return callableObject || protoApplicator;
  }


  function isApplicator(type) {
    return (!!type && (

      (type instanceof Applicator) || (

           (typeof type == "object")

        && isFunction(type.call)
        && isFunction(type.apply)
        && isFunction(type.valueOf)

        && isFunction(type.valueOf())
      )
    ));
  }
  // function prototypalToApplicator() {
  //   return toApplicator(this);
  // }


//functionPrototype.toApplicator = prototypalToApplicator;

  Function.toApplicator = toApplicator;       // - factory
  Function.isApplicator = isApplicator;       // - utility
                                              //
  Function.isCallable   = isCallable;         // - utility
  Function.isFunction   = isFunction;         // - utility


  Applicator.prototype = toApplicator(functionPrototype);
//Applicator.prototype = functionPrototype.toApplicator();


//return Function;


}(Function, Object, Array));



/*


  [http://closure-compiler.appspot.com/home]


- Simple          -   867 byte
(function(d,g,e){function f(){return this}function l(a){this.call=function(){var b=h(arguments),c=b.shift();a.apply(null!=c&&c||null,b)};this.apply=function(b,c){c=h(c);a.apply(null!=b&&b||null,c)};this.valueOf=function(){return a};this.toString=function(){return["Applicator :: ",a].join("")};return this}function k(a){var b;c(a)&&(b=new f,l.call(b,a));return b||a}g=d.prototype;var c=function(a){return function(b){return typeof b==a&&typeof b.call==a&&typeof b.apply==a}}("function"),h=c(e.from)&&e.from||function(a){return function(b){return a.call(b)}}(e.prototype.slice);d.toApplicator=k;d.isApplicator=function(a){return!!a&&(a instanceof f||"object"==typeof a&&c(a.call)&&c(a.apply)&&c(a.valueOf)&&c(a.valueOf()))};d.isCallable=function(a){if(a){var b=!0;try{a()}catch(m){b=!1}a=b}else a=!1;return a};d.isFunction=c;f.prototype=k(g)})(Function,Object,Array);


*/


var Enumerable_first = function () {
  this.first = function () {

    return this[0];
  };
};
var Enumerable_last = function () {
  this.last = function () {

    return this[this.length - 1];
  };
};
console.log('before `toApplicator` :: isCallable(Enumerable_first) ? ', Function.isCallable(Enumerable_first));
console.log('before `toApplicator` :: isCallable(Enumerable_last) ? ', Function.isCallable(Enumerable_last));


Enumerable_first = Function.toApplicator(Enumerable_first);           //  callable object ("objectified" function)
Enumerable_last = Function.toApplicator(Enumerable_last);             //  callable object ("objectified" function)

console.log('after `toApplicator` :: isCallable(Enumerable_first) ? ', Function.isCallable(Enumerable_first));
console.log('after `toApplicator` :: isCallable(Enumerable_last) ? ', Function.isCallable(Enumerable_last));


var Enumerable_first_last = function () {
  Enumerable_first.call(this);
  Enumerable_last.call(this);
};
console.log('before `toApplicator` :: isCallable(Enumerable_first_last) ? ', Function.isCallable(Enumerable_first_last));


Enumerable_first_last = Function.toApplicator(Enumerable_first_last); //  callable object ("objectified" function)

console.log('after `toApplicator` :: isCallable(Enumerable_first_last) ? ', Function.isCallable(Enumerable_first_last));


Enumerable_first_last.call(Array.prototype); // applying the `Enumerable_first_last` trait.


var list  = "the quick brown fox jumped over the lazy dog".split(" ");

console.log('list : ', list);
console.log('list.first(); : ', list.first());
console.log('list.last(); : ', list.last());

console.log('Enumerable_first.valueOf() : ', Enumerable_first.valueOf());
console.log('Enumerable_first.toString() : ', Enumerable_first.toString());
console.log('Enumerable_first_last.valueOf() : ', Enumerable_first.valueOf());
console.log('Enumerable_first_last.toString() : ', Enumerable_first.toString());

console.log('Function.isApplicator(Enumerable_last) ? ', Function.isApplicator(Enumerable_last));
console.log('Function.isApplicator(Enumerable_first_last) ? ', Function.isApplicator(Enumerable_first_last));

</script>
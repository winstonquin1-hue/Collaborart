var myButton = {
  content: 'OK',
  click() {
    console.log(this.content + ' clicked');
  }
};

myButton.click();

var looseClick = myButton.click;
looseClick(); // not bound, 'this' is not myButton - it is the globalThis

var boundClick = myButton.click.bind(myButton);
boundClick(); // bound, 'this' is myButton

Which prints out:

OK clicked
undefined clicked
OK clicked

----------------------------------------------------------------------------


var whatsThis = function() { console.log(this); }

whatsThis.call('hello');

// Call a function that takes a variable number of args
console.log(Math.max.call(undefined, 3, 20, 1, 45));
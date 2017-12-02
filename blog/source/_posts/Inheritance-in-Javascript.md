title: Inheritance in Javascript
date: 2017-04-23 21:54:39
tags: [javascript]
categories: Coding
thumbnail: /images/inheritance.png
---

Javascript uses prototype chains to make inheritance work, that’s a little odd given that other OOP languages usually use `class` and `extend`. So to fully understand inheritance in javascript, we first have to understand what prototype chain is.

Let’s say we have a function.

```javascript
function Animal() {
      this.category = 'organism';
      this.food = 'generic food';
}
console.log(Animal.prototype.constructor); // [Function: Animal]
```

As shown in the above code, when we define a function, javascript also adds a special property called `prototype` on that function at the same time. And you can see that another special property `constructor` is automatically created on `function.prototype`, which is `Animal.prototype.constructor` in the above code. You can take the property as the function itself, when we create an instance using something like `var animal = new Animal()`, javascript will create the instance using the constructor specified by `Animal.prototype.constructor`.

```javascript
let animal = new Animal();
```

What happens under the hood when the above line gets executed is that:

1.  A new object is created, which is called `animal`.
2.  A property called `animal.__proto__` is created, and `animal.__proto__ === Animal.prototype`.
3.  It calls `Animal()` in the context of `animal,` which means following lines get executed.

```javascript
animal.category = 'organism';
animal.food = 'generic food';
```

So let’s sum up what happens here with a diagram.

![what happens when we new an instance](/images/Inheritance-in-Javascript-1.png)

1.  `animal.__proto__` is the same as `Animal.prototype.`
2.  `animal.category` is `organism`.
3.  `animal.food` is `generic food`.

Nothing is wrong here, we get all of animal’s custom properties(`category` and `food`) with or without `__proto__`, so what is it used for? Let’s add a line here.

```javascript
Animal.prototype.walk = 'animals can walk';
console.log(animal.walk); // animals can walk.
```

This is where the interesting part comes in. We know that `animal` doesn’t have a property called `walk`. So to find it, javascript resort to `animal.__proto__`, aka `Animal.prototype` to see if `Animal.prototype` has a property called `walk`. You know what? We just defined it! So javascript fetches the value of walk and returns it. So it looks like animal has a `walk` property itself!

![the process of looking for a property](/images/Inheritance-in-Javascript.svg)

In this way, we can define another object called `Cat`, which inherits from `Animal`.

```javascript
function Cat() {
      this.food = 'fish';
}

Cat.prototype = animal; // all instances created by Cat inherit from Animal
let cat = new Cat();

console.log(cat.category); // organism
console.log(cat.food); // fish
console.log(cat.walk); // animals can walk
console.log(cat.constructor); // [Function: Animal]
```

![prototype chain](http://searene.party/wp-content/uploads/2017/04/Inheritance-in-Javascript-3.png)

You see, `cat` has all properties that we defined in `Animal`, including `category`, `walk`, and our `cat` even overrides `Animal`‘s `food`, because we all know, cat likes to eat `fish`. Something familiar? Yes, this is called inheritance! We just implemented inheritance in javascript!

But do you know how `cat.walk === 'aniamls can walk'` works? It follows several steps.

1.  Check if `cat` has a property called `walk`, obviously it doesn’t have that.
2.  Check if `cat.__proto__`, which is `Cat.prototype`, which is also `animal` has that property, obviously `animal` also doesn’t have it.
3.  Check if `cat.__proto__.__proto__` has the `walk` property, OK, this time `cat.__proto__.__proto__` aka `Animal.prototype` has that `walk` property, return its value, the job is done here.

So you can see, `__proto__` is just like a chain, to check if an instance `cat` has a property `walk`, we need to check:

1.  `cat.walk`
2.  `cat.__proto__.walk`
3.  `cat.__proto__.__proto__.walk`
4.  `cat.__proto__.__proto__.__proto__.walk`
5.  …

And because `cat.__proto__` is the same thing as `Cat.prototype`, to inherit `cat` from `Animal`, what we need to do is just point `Cat.prototype` to `animal`, so `cat` could have all properties `animal` has in this way.

One thing is left here. We find out that `cat.constructor` equals `[Function: Animal]`, this may not be what we want. `cat` is created by `Cat` instead of `Animal`, so we need to add another line here.

```javascript
Cat.prototype.constructor = Cat;
```

This is the complete code.

```javascript
"use strict";

function Animal() {
  this.category = 'organism';
  this.food = 'generic food';
}

Animal.prototype.walk = 'animals can walk';

function Cat() {
  this.food = 'fish';
}

Cat.prototype = new Animal(); // all instances created by Cat inherit from Animal
Cat.prototype.constructor = Cat; // change the constructor back

let cat = new Cat();

console.log(cat.category); // organism
console.log(cat.food); // fish
console.log(cat.walk); // animals can walk
console.log(cat.constructor); // [Function: Cat]
```

Let's make it more concise.

```javascript
"use strict";
function Animal() {
}
function Cat() {
}
Cat.prototype = new Animal(); // all instances created by Cat inherit from Animal
Cat.prototype.constructor = Cat; // change the constructor back

var cat = new Cat();
```

This can also be written as

```javascript
"use strict";
function Animal() {
}
function Cat() {
  Animal.call(this)
}

Object.setPrototypeOf(Cat.prototype, Animal.prototype); // set Cat.prototype as Animal.prototype, notice that this line won't change Cat.prototype.constructor, so it will remain as Cat

var cat = new Cat();
```

In fact, we also need to do anther things like changing the super class of `Cat`, so a function called `Object.inheritance` was created to do this sort of work, which would modify the super class of the child class and set the child class' prototype as the parent's.

```javascript
"use strict";

var util = require("util");

function Animal() {
}

function Cat() {
  Animal.call(this)
}

util.inherits(Cat, Animal);

// If you want to add some properties to Cat.prototype, make sure they are added after util.inherits, or these properties will not work because util.inherits will overwrite those properties
Cat.prototype.eat = function() {
  console.log("Cat is eating");
}

var cat = new Cat();
```

That's it, the above code is one of the most common ways to achieve inheritance.

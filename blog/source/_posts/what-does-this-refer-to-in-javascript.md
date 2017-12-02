title: what does "this" refer to in javascript?
date: 2017-05-15 23:30:32
tags: javascript
categories: Coding
thumbnail: /images/This-Guy-Rocks1.jpg
---

# Introduction
`this` in javascript is always a mysterious thing. Some programmers who have written a lot of javascript code still cannot tell the value of `this` every now and then. So today, I decided to write an article about it to solve the problem once and for all. I think you would be able to fully understand what `this` refers to in almost all situations after you read this article.

# Rule 1: Basic Rule
<div style="background-color: #fff5cc; border-color: #ffe273; padding: 10px; border-left: 10px solid #ffe273">**Rule 1**: When `this` is used in a normal function(i.e. not an arrow function), `this` refers to the object that calls the function.</div>

This is the most important rule, let's use several examples to illustrate what it means.

#### when the function is called by an object.

```javascript
var obj = {
    foo: function() {
        console.log(this); // this?
    }
};
obj.foo();
```

`this` is in a normal function `foo`, and `foo` is called by `obj`. So `this` refers to `obj` here.

<div style="border: 1px solid #c8c8c8; padding: 10px; border-radius: 5px;">answer: **obj**</div>

#### when the function is called all by itself.

```javascript
function foo() {
    console.log(this); // this?
}

foo();
```

This is different, nothing calls `foo()`, right? Well, not exactly. In fact, `foo()` is the same as `window.foo()`, so `this` refers to `window` here, which is the global object in javascript.

<div style="border: 1px solid #c8c8c8; padding: 10px; border-radius: 5px;">answer: **window**</div>

#### when the function is assigned to another function

```javascript
var obj = {
    foo: function() {
        console.log(this); // this?
    }
};
var bar = obj.foo;
bar();
```

This time the function that gets executed is not `obj.foo`, it's `bar`, because `obj.foo` is assigned to `bar`.

`this` refers to object that calls `bar` instead of `obj.foo` in this case, because `obj.foo` has been assigned to `bar`. Who calls `bar`? `window`. So `this` refers to `window` here.

<div style="border: 1px solid #c8c8c8; padding: 10px; border-radius: 5px; margin-bottom: 30px">answer: **window**</div>

<div style="background-color: #EBF4F7; border-color: #ffe273; padding: 10px;">**A Gotcha Moment**: `this` is only injected into context when the function which contains `this` is called. We cannot determine the value of `this` only by its definition. We have to see who calls `this` to determine its value. You can find it in the above code that the value of `this` may be different when it's called in different ways.</div>


# Rule 2: Eval
<div style="background-color: #fff5cc; border-color: #ffe273; padding: 10px; border-left: 10px solid #ffe273">**Rule 2**: `this` remains unchanged when evaluated using `eval` directly, and is equal to `window` when evaluated using `eval` indirectly.</div>

Using `eval` directly means something like: `eval('this')`.
Using `eval` indirectly means something like `(1, eval)('this')`.

Let's look at the code first.

```javascript
var obj = {
    foo: function() {
        console.log(eval('this')); // this?
    }
};
obj.foo();
```

To solve the problem, let's first insert another line in the above code.

```javascript
var obj = {
    foo: function() {
    	console.log(this) // <-- insert this line
        console.log(eval('this')); // this?
    }
};
obj.foo();
```

Do you know what `this` in the inserted line refers to? Of course it's `obj`, we have talked about it a while before. So what's the value of `eval('this')`? It's exactly the same, `obj`! It doesn't change.

<div style="border: 1px solid #c8c8c8; padding: 10px; border-radius: 5px;">answer: **obj**</div>

What if we use `eval` indirectly?

```javascript
var obj = {
    foo: function() {
        console.log((1, eval)('this')); // this?
    }
};
obj.foo();
```

When `eval` is used indirectly, `this` in it refers to `window`, simple rule.

<div style="border: 1px solid #c8c8c8; padding: 10px; border-radius: 5px;">answer: **window**</div>

# Rule 3: Arrow Functions
<div style="background-color: #fff5cc; border-color: #ffe273; padding: 10px; border-left: 10px solid #ffe273">**Rule 3**: `this` in arrow functions is the same as `this` in the outer context.</div>

Still, code first.

```javascript
function bar() {
    var obj = {
        foo: () => {
            console.log(this); // this?
        }
    };
    obj.foo();
}
bar();
```

OK, this time, `this` is used in an arrow function. According to **Rule 3**, we have to find out what `this` is in the outer context with respect to the arrow function `obj.foo`. Some people don't know what *outer context* is. Actually, the outer context can be seen as the context where `obj.foo` gets executed.

Let's insert another line in the above code.

```javascript
function bar() {
    var obj = {
        foo: () => {
            console.log(this); // this?
        }
    };
    console.log(this); // <-- insert this line
    obj.foo();
}
bar();
```

Do you know what `this` refers to in the inserted line? Of course, it refers to `window`, because it's `window` that calls `bar`. So what `this` refers to in the original code(the 4th line)? It's the same! Because the outer context of `obj.foo` is exactly the context where the inserted line is in.

<div style="border: 1px solid #c8c8c8; padding: 10px; border-radius: 5px;">answer: **window**</div>

# Rule 4: Event handler
<div style="background-color: #fff5cc; border-color: #ffe273; padding: 10px; border-left: 10px solid #ffe273">**Rule 4**: `this` refers to `window` when used an inline event handler, and refers to the attached DOM element when used in a separate event hanlder.</div>

#### inline event handler

```html
<html>
<head></head>
<body>
    <button id="button" onclick="foo()">Click me!</button>
    <script type="text/javascript">
        function foo() {
            alert(this);
        }
    </script>
</body>
</html>
```

`this` is used in an inline event handler `foo` here, so `this` refers to `window`.
<div style="border: 1px solid #c8c8c8; padding: 10px; border-radius: 5px;">answer: **window**</div>

#### separate event handler

```html
<html>
<head></head>
<body>
    <button id="button">Click me!</button>
    <script type="text/javascript">
        var button = document.getElementById("button");
        button.onclick = function foo() {
            alert(this);
        }
    </script>
</body>
</html>
```

`this` is used in a separate event handler `foo` here. So it refers to the DOM element `button` according to **Rule 4**. In fact, we can also use **Rule 1** to get the same answer. Because each time the button is clicked, `button.onclicked` is executed. Who calls the `onclick` function? `button`. So the answer is `button`.

<div style="border: 1px solid #c8c8c8; padding: 10px; border-radius: 5px;">answer: **button(DOM element)**</div>

# Rule 5: JQuery
<div style="background-color: #fff5cc; border-color: #ffe273; padding: 10px; border-left: 10px solid #ffe273">**Rule 5**: `this` in most JQuery callbacks refers to the attached JQuery element</div>

```html
<html>

<head>
    <script src="/jquery-2.2.4.js"></script>
</head>

<body>
    <button id="button">Click me!</button>
    <script type="text/javascript">
        $("button").click(function() {
            alert(this);
        })
    </script>
</body>
</html>
```

According to **Rule 5**, `this` refers to `$("button")` here. You may wonder why it is the case. In fact, JQuery calls the callback using something like this:

```javascript
function click(callback) {
	callback.call($("button"))
}
```

`callback.call($("button"))` is the same as `callback()`, except that it sets the `this` in `callback` as `$("button")`, so you can happily use `this` as the JQuery element inside the callback function.
<div style="border: 1px solid #c8c8c8; padding: 10px; border-radius: 5px;">answer: **button(JQuery object)**</div>

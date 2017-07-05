---
categories: [Programming, Development]
date: 2016-04-15T07:40:17+07:00
description: "How to write function composition in Go"
draft: false
keywords: ["programming", "go", "golang", "combinators", "function composition", "javascript", "composition"]
series: []
socialsharing: true
tags: ["programming", "golang", "function composition"]
title: Function Composition in Go
totop: true
---
I've been playing with functional JavaScript for a while, especially partial
applications and function composition, and I find those concepts are very
helpful in my daily coding practices. At first, if you are short in
[mathematical logic systems][wiki-logic-wiki] (just like me), making sense
anything functional could be a bit out of hand. Fortunately there are a lot
of reading materials that do a great job explaining the concepts in an easy and
pragmatic way. You could [search those articles in medium][medium-functional-js]
and/or you would want to read this [book][js-alonge].

Go, by design is quite different from JavaScript. It is an attempt to combine
the ease of programming of an interpreted, dynamically typed language (e.g., JavaScript) with the efficiency and safety of a statically typed,
compiled language. It also aims to
be modern, with support for networked and multicore computing
([Go FAQ page][go-faq-why], 2016). However, despite the differences, there are some similarities
between JavaScript and Go, one of them is that they treat
[functions as first class object][wiki-first-class-function],
which means function is an object that can be passed
around as function's arguments or can be returned from other functions,
and yes, function is a type in Go.

```
type fnString func(string) string
```

The effect of having first-class functions is that we can write Go in a more functional manner, just similar to JavaScript.
In JavaScript we can easily write a `compose` function (function to do
[function composition][wiki-fn-composition]) as the following.

```js
const compose = (a, b) => (val) => a(b(val));

// variadic versions
const compose = (...functions) =>
  (value) => functions.reverse().reduce((acc, fn) => fn(acc), value);
```

In Go, as it is a typed language, and
[it does not support generic type][go-faq-generics]
per se, first we need to define a type of what the `compose` function
will work against.

```
type fnString func(string) string
```

Here, we define `fnString` of function type that receives a `string`
argument and returns a `string`. Next, is to define the `compose`
function itself.

```
func compose(a fnString, b fnString) fnString {
	return func(s string) string {
		return a(b(s))
	}
}
```

The `compose` code is pretty straight forward just like the JavaScript
version. The only main difference is that the function has to comply with the
given type, `fnString` in the example above. So if we want to compose functions
that work on other than strings, we might need to define the appropriate type and the appropriate `compose` function (as Go does not have generic type),
in contrast to the JavaScript version that will work for all type
---JavaScript is a dynamic programming language after all.

Then, how about the variadic version? Fortunately, Go supports variadic
arguments so it is easier to port the JavaScript code into Go.
However, Go does not
provide direct translation of JavaScript's `Array.reduce` function, the
only way to compose the functions is by iterating through the passed
functions and compose them one into another.

```
func compose2(a fnString, b fnString) fnString {
	return func(s string) string {
		return a(b(s))
	}
}

func compose(fns ...fnString) fnString {
	return func(s string) string {
		var res fnString
		res = fns[0]
		for i := 1; i < len(fns); i++ {
			res = compose2(res, fns[i])
		}
		return res(s)
	}
}
```

As seen in the code, the functions are iterated by using a `for` statement. Another
way to loop over the functions is by recursion (as mentioned by _Whargharbl_) in the comment
section.

```
func composeRec(fns ...fnString) fnString {
	return func(s string) string {
		f := fns[0]
		fs := fns[1:len(fns)]

		if len(fns) == 1 {
			return f(s)
		}

		return f(composeRec(fs...)(s))
	}
}
```

The working example of the above function composition can be seen on
https://play.golang.org/p/l0bKbeDQ8x

{{< sectionsign >}}

Even though writing Go code in a more functional style is possible, however, Go is not a functional programming language. Hence, I'm still not convinced
that writing Go program in a functional manner entirely is a good approach (if that is even possible), but I might be wrong.

**Update**

**[05/07/2017]**: Added the recursive version of compose as _Whargharbl_ mentioned.


[wiki-logic-wiki]: https://en.wikipedia.org/wiki/Mathematical_logic
[js-alonge]: https://leanpub.com/javascript-allonge/read
[medium-functional-js]: https://medium.com/search?q=functional%20javascript
[go-faq-why]: https://golang.org/doc/faq#creating_a_new_language
[wiki-first-class-function]: https://en.wikipedia.org/wiki/First-class_function
[wiki-fn-composition]: https://en.wikipedia.org/wiki/Function_composition_%28computer_science%29
[go-faq-generics]: https://golang.org/doc/faq#generics

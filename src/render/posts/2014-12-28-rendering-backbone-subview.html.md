---
layout: post
title: "Rendering Backbone (Sub)View"
date: 2014-12-28 19:31
comments: true
tags: backbone.js, view, javascript
---

When learning backbone.js (i'm a novice by the way), at first, I was actually having a hard time
to grasp the backbone view. Especially how the best practice to render
the view and build a rather complex view consists of several subviews.
And then, magically I came accross Ian Storm Taylor's post about 
[his experience on dealing with backbone subview](http://ianstormtaylor.com/rendering-views-in-backbonejs-isnt-always-simple/).
At first I didn't quiet understand well about the post until I found
[a thread on stackoverflow](http://stackoverflow.com/questions/9337927/how-to-handle-initializing-and-rendering-subviews-in-backbone-js), which was started by [Ian Storm Taylor](http://ianstormtaylor.com).

Based on the posts, I created a simple case study to better understand how it works.
The requirements were to list pairs of username and email input by users.
So at first I created the view as listed below:

``` html
<div id="application">
  <p>backbone view example</p>
  <div id="login"></div>
  <ul id="online-users"></ul>
</div>
<script id="login-template" type="text/template">
    <h1> login </h1>
    <input id="username" type="text" placeholder="username" /> 
    <input id = "email" type = "text" placeholder = "email" /> 
    <button id = "button-login" type = "button"> Login </button>
</script>
<script id="userlist-template" type="text/template">
    <li><%= username %> / <%= email %></li>
</script>
```
To better visualize, lets see this picture:

![Application view][pic:app-view]

The outer container is `#application` and inside it there are
two other sub-containers `#login` and `#online-users`. Each container
or sub-container is represented in a separated view. However,
there is an exception for the last view where the view is 
created for each username-password pair then appended in 
the container `#online-users`.

So here is the application view, a _master_ view that 
contains all other view.

```javascript
app.AppView = Backbone.View.extend({
  el: '#application',

  initialize: function () {
      this.users = new app.UserList();
      
      this.loginView = new app.LoginView();
      
      this.listenTo(this.users, 'add', this.renderOne);
      this.listenTo(this.loginView, 'login', this.login);
      this.listenTo(this.users, 'reset', this.renderAll);

      this.users.fetch();
  },

  render: function () {
      this.loginView.setElement(this.$('#login')).render();
      this.users.each(this.renderOne, this);
  },
  
  renderOne: function (user) {
      var view = new app.UserView( { model: user } );
      view.setElement(this.$('#online-users')).render();
  },

  renderAll: function () {
    this.users.each(this.renderOne);
  },
  
  login: function (user) {
      this.users.create( user );
  }
});
```

Above are examples for rendering subviews using backbone.js.

[pic:app-view]: /images/backbone-view-schema.png
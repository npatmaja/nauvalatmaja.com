---
title: "Rendering Backbone (Sub)View"
date: 2014-12-29
tags: [code, Backbone, subview, Backbone view]
categories: [Development, Web]
socialsharing: true
totop: true
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

```html
<div id="application">
  <p>Add a user to the user list</p>
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
  <li>
    <span><%= username %> / <%= email %></span>
    <button id = "force-logout">force logout</button>
  </li>
</script>
```
To better visualize, lets see this picture:

![Application view][pic:app-view]

<!-- Read more -->

The outer container is `#application` and inside it there are
two other sub-containers `#login` and `#online-users`. Each container
or sub-container is represented in a separated view: `AppView`, `LoginView`
and `UserListView` respectively. To make it
nicely structured, the `UserListView` has a sub-view
called `UserView` that renders each pair of username and email
handles of the button clicked event.
there is an exception for the last view where the view is
created for each username-password pair then appended in
the container `#online-users`.

Now let's get to the code.
```javascript
app.AppView = Backbone.View.extend({
  el: '#application',

  initialize: function () {
    this.users = new app.UserList();

    this.loginView = new app.LoginView();
    this.userListView = new app.UserListView( { collection: this.users } );

    this.listenTo(this.loginView, 'login', this.login);
  },

  render: function () {
    this.loginView.setElement(this.$('#login')).render();
    this.userListView.setElement(this.$('#online-users')).render();
  },

  /* ... */

  login: function (user) {
    this.users.create( user );
  }
});

app.LoginView = Backbone.View.extend({
  template: _.template($('#login-template').html()),

  events: {
    'click #button-login': 'login'
  },

  render: function () {
      this.$el.html(this.template());
  },

  login: function () {
    // login logic
  },

  /* ... */
});
```
Here, the most important thing to connect Backbone view to
the html is the `el` (element) property. The `el` property defines to
which element the view template will be rendered, or at least in this case
study. In the `AppView` the `el` is set to `#application`
as the root container of the application. However, for its
sub-views, the `el` property is not defined in the view
definition but set dynamically using `setElement` method.
As Ian suggested, this is done to avoid the unbinding of
sub-views' events when rendered more than a time.

The instantiation
of sub-views depends on how the sub-views are rendered.
`LoginView` and `UserListView` are instantiated in
the `initialize` method as the application only need
an instance for each of them. In contrast, `UserView`
is instantiated for each user (model) as it needs to
associate the button click event inside the view with
the contained model.

```javascript
app.UserListView = Backbone.View.extend({
  initialize: function () {
    this.listenTo(this.collection, 'add', this.renderOne);
    this.listenTo(this.collection, 'reset', this.renderAll);
  },

  render: function () {
    this.renderAll();
  },

  renderOne: function (user) {
    var view = new app.UserView( { model: user } );
    this.$el.append(view.render().el);
  },

  renderAll: function () {
    this.collection.each(this.renderOne);
  }
});

app.UserView = Backbone.View.extend({
  template: _.template($('#userlist-template').html()),
  tagName: 'li',
  events: {
      'click #force-logout': 'clear'
  },

  initialize: function () {
    this.listenTo(this.model, 'destroy', this.remove);
  },

  render: function () {
      this.$el.html( this.template( this.model.attributes ) );
      return this;
  },

  clear: function () {
      this.model.destroy();
  }
});
```
To make the code structured nicely, I used the `html()` and
`append()` method of Backbone view's `$el` property. Some people
might use jquery's selector `$('.element')` to render the html,
which I think it isn't clean enough. Lastly, I've made a [fiddle][jsfiddle]
about this post where you can play around. Hope this post
helps someone to understand more about backbone view.

[pic:app-view]: /img/backbone-view-schema.png
[jsfiddle]: http://jsfiddle.net/npatmaja/csL45j3s/

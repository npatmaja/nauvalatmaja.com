---
layout: post
title: "Upload Files with Backbone.js, Node.js and express 4.x"
date: 2015-01-30 13:00
comments: true
tags: [Node.js, express, Backbone.js, upload, multer, "Backbone Fundamentals"]
---
[Backbone fundamentals](https://github.com/addyosmani/backbone-fundamentals)
is a great *free* resource to learn Backbone.js from scratch. The book was written by 
[Addy Osmany](http://addyosmani.com/) under [creative-commons license](https://en.wikipedia.org/wiki/Creative_Commons_license).
As its second exercise, the book guide the readers to create a simple library application
that uses Node.js as the back-end. However, it left the part to upload book's cover
to the readers as an exercise. Hence, here is the way I did it.

# Requirement
There are two additional requirements for the upload book's cover features:
- The selected cover should be previewed as thumbnail
   
  This implies that there should be a space to show the selected
  image. When users change the image, the preview should change 
  accordingly.

- Upload process shall happen only when a new book is added
   
  The upload happens if and only if when users click the button
  to add a new book. This signifies that the displaying the cover's
  preview should not upload to image file to the server.


# Problems
After browsing for awhile, I found [a blog post to upload file asynchronously using Node.js and express](http://markdawson.tumblr.com/post/18359176420/asynchronous-file-uploading-using-express-and), which was good
as a starting point. However, similar to most of online references I had found, 
they were pretty much obsolete; most of them were using express <= 3.x that supported file upload
by using `body-parse` middleware (as mentioned in the blog post) where in express
4.x the `body-parse` middleware did not support file upload any longer.

Another problem was to address the requirement: previewing images without
upload them to the server in the first place. This was tricky, as most of the 
solutions were to have the images uploaded first then fetch the images' URL 
to be previewed.

# Solution
I had to admit, the first problem is another RTFM problem. So when I read again
[`body-parser`'s documentation](https://github.com/expressjs/body-parser) it was
written clearly that `body-parse` did not handle multipart bodies (file uploads).
Furthermore, it mentioned the alternatives modules to handle multipart bodies, and
one of them is [multer](https://www.npmjs.com/package/multer#readme).

Just like another express middleware, I needed to tell express to use multer and
specified to which directory the files will be uploaded as shown in the following
coffeescript code (yes, I wrote the back-end using coffeescript).

``` coffeescript
express = require 'express'
multer = require 'multer'

app = express()
app.use multer( { dest: "#{__root}/public/img/covers/" } )
```
For the second problem, I found out that javascript provides a 
[`FileReader` object whose capable of reading file from client's machine](https://developer.mozilla.org/en-US/docs/Web/API/FileReader), 
[which could be used to load a selected image from a browser locally](https://developer.mozilla.org/en-US/docs/Using_files_from_web_applications#Example.3A_Showing_thumbnails_of_user-selected_images).

The following code is a Backbone view to handle the feature to display the selected image.
The main idea is to catch the `change` event from an `<input type="file">` and read the file
and render it through the designated `<img>` element and later on to upload the file as well.

```
app.ThumbnailView = Backbone.View.extend({
  events: {
    'change #coverImageUpload': 'renderThumb',
    'submit #uploadCoverForm': 'upload'
  },

  render: function () {
    this.renderThumb();
  },

  renderThumb: function () {
    var input = this.$('#coverImageUpload');
    var img = this.$('#uploadedImage')[0];
    if(input.val() !== '') {
      var selected_file = input[0].files[0];
      var reader = new FileReader();
      reader.onload = (function(aImg) { return function(e) { aImg.src = e.target.result; }; })(img);
      reader.readAsDataURL(selected_file);
    }
  },

  submit: function () {
    this.$form = this.$('#uploadCoverForm');
    this.$form.submit();
  },

  upload: function () {
    var _this = this;
    this.$form.ajaxSubmit({
      error: function (xhr) {
        _this.renderStatus('Error: ' + xhr.status);
      },
      success: function (response) {
        _this.trigger('image-uploaded', response.path);
        _this.clearField();
      }
    });
    return false;
  },

  renderStatus: function (status) {
     $('#status').text(status);
  },

  clearField: function () {
    this.$('#uploadedImage')[0].src = '';
    this.$('#coverImageUpload').val('');
  }
});
```

The uploading part was a bit tricky. I used Backbone View's event to make sure
that the newly added book has the right cover image. The way to do this is to
make sure when a user clicks the __add book button__, the cover image
will be uploaded first and when the the upload success an event will be 
triggered with the server path of the uploaded image as the parameter. Then the path will 
be used as the value of `<input>` related to the book cover. The last step
is to create the book object in the Backbone Collection, which will be 
sync'd to the Node.js back-end server. The following sequence diagram 
pictures the description above.

```
sequenceDiagram
  User->>LibraryView: click add book button
  LibraryView->>ThumbnailView: upload
  ThumbnailView->>ThumbnailView: trigger('uploaded', response.path)
  opt uploaded event
    LibraryView->>LibraryView: updateInput
    LibraryView->>LibraryView: createData
  end
```

To enable the event in the `LibraryView`, the object needs to listen to
to the `ThumbnailView`.

```
app.LibraryView = Backbone.View.extend({
  ...

  initialize: function (initialBooks) {
    this.collection = new app.Library(initialBooks);

    this.thumbnailView = new app.ThumbnailView();
    this.bookListView = new app.BookListView( { collection: this.collection } );

    this.listenTo(this.thumbnailView, 'image-uploaded', this.updateInput);
  }
}
```

And that's all folks! The complete solution can be seen [here](https://github.com/npatmaja/library).
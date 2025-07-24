# EmbeddableAsset Gem
 - Supports Rails 3 and 4
 - Supports both Sass and CSS
 - Dynamically embed your assets into your Stylesheets
 - Generate Stylesheets completely indepedent of external assets!


This is a simple gem that makes embedding your assets directly in your CSS very easy!
The goal is to generate stylesheets completely independent of all external asset resources.
This is achieved through CSS data-uri (i.e. encoding an asset's data directly into the file in base64).
This gem packages up some already existing Rails helpers meant for generating data-uris via the asset pipeline.
On top of those rails helpers is a wrapper that allows for conditionally embedding or not embedding (unembedding) your assets via Rake tasks.
In otherwords, precompile assets as normal, unless you specifically want them to be embedded. Hence the duality of the gem name "Embeddable",
denoting that a given asset may or may not be embedded depending on how you run it.


## Why would I use this?
Most of the time you want the rails asset pipeline to behave normally when deploying to production (i.e. linking to assets instead of embedding them).
However there are situations when you might want to package your stylesheet and the external assets it links to (like images, fonts, etc.) into
a single application.css file that does not have any dependencies. For example, if you want to have a completely static "down page"
that is served by a proxy in the event your main production server goes down, you might want to serve a single static html file that has all of the
styles, JS, images, fonts, etc. embedded inside of it. Yes, the embedding makes the file size signigicantly larger, however you would only use this for
special situations like this. Another usage example, might be a simple and convienant way to package up a page you are building or want to show someone non-technical.
You could simply compile that page into a single file, assets and all, and send it in an email. Then the receiver doesn't need a server or a bunch of files to make it work.
They can simply open a single file in their browser and interact with it.



## Installation (STEP 1/3)

Add this line to your application's Gemfile:

```ruby
gem 'embeddable_asset'
```

And then execute:

    $ bundle

## Using the embeddable helpers (STEP 2/3)
**Specify which assets should be embedded**

#### Via CSS
You must use the *css.erb extension in files you wish to use the helpers in:

```css
@font-face {
  font-family: myFirstFont;
  src: <%= embeddable_asset('chopin_script.ttf') %>;
}

h2 {
  font-family: myFirstFont;
  padding: 12px;
  background-image: <%= embeddable_image(asset_path 'duck.jpg') %>;
}
```


#### Via Sass
Import the helper file in application.scss:

```css
@import 'embeddable_asset';
/* now other Sass and imports below it can use helper functions */
...
```

Now you can call Sass helper functions
```css
...
@font-face {
  src: embeddable-asset('chopin_script.ttf');
  font-family: myFirstFont;
}

h2 {
  font-family: myFirstFont;
  padding: 12px;
  background-image: embeddable-image('duck.jpg');
}
```

## Running the Rake Tasks (STEP 3/3)
Only use the embeddable helpers on assets you want to be embedded.
This is an opt-in helper so you can limit which assets get embedded.


#### Precompile with embedded assets

    $ bundle exec rake assets:precompile:embed

```css
/* Will turn this... */
h2 {
	background-image: embeddable-asset('duck.jpg')
}

/* ...Into this */
h2 {
	background-image: url(data:image/jpeg;base64,%2F9j%2F2wBBAQEBAQEBAQ...)
}
```

#### Precompile with unembedded assets
NOTE: Because the asset pipeline caches precompiled assets, rerunning any kind of additional precompile rake task on its own would normally not force a recompile if the assets haven't been changed.
It would simply just reuse the same assets. So running "rake assets:precompile:embed" followed by "rake assets:precompile"
would simply reuse the precompiled-embedded assets from the first command.

To ensure assets do not get embedded after running the embed command, you can use:

	$ bundle exec rake assets:precompile:unembed

This is essentially the equivalent of "rake assets:precompile", however it will make sure to ignore any previously cached assets.

```css
/* Will turn this... */
h2 {
	background-image: embeddable-asset('duck.jpg')
}

/* ...Into this */
h2 {
	background-image: url(/assets/duck-e5ff3efc549760d.jpg)
}
```



## Troubleshooting
#### "WARNING: Unable to initialize EmbeddableAsset helpers."
You will see this warning in the terminal output or logs when
the current RAILS_ENV (i.e. test, development, production) has the
asset pipeline compilation disabled. Make sure the config file for the environment you are trying to run the rake task in has this setting
enabled like so:

```ruby
config.assets.compile = true
```

#### Why aren't my precompiled assets being minified?
This also has to do with environment specific config options as explained above. In order to ensure assets are minified, set the appropriate config options in the config file corresponding with the RAILS_ENV you are trying to run the rake task in. These config options will be different depending on if you are using CSS or Sass / Rails 3 or 4. You will want to look up the config options specific to your use case. The production environment config file usually has the desired minification settings specific to your project, so you could alternatively run the rake task like so:

    $ RAILS_ENV=production rake assets:precompile:embed


## Running the tests
This Gem is tested by utilizing two seperate nested dummy projects in order
to best simulate the environments this gem will be used in.
One project is using Sass via Rails 4.2, and the second is using CSS via Rails 3.2.
In order to run the tests, you must clone this project and "cd" into the appropriate sub-dummy-project and run:

	$ cd path/to/sub-dummy-project
    $ bundle exec rspec


## Contributing
Bug reports and pull requests are welcome!


## License
The gem is available as open source under the terms of the [MIT License](LICENSE.txt).

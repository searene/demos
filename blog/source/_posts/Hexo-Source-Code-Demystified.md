title: Hexo Source Code Demystified
date: 2016-07-17 07:52:23
tags:
categories: Coding
thumbnail:
---

# Preface
Hexo is an excellent static blog generator, I read its source code recently, and I think it's worth sharing the inner mechanism of its source code.

# Generator
When you run the command `hexo generate`, hexo will generate all the static files for you. This is the part we are going to start with. The directory where `hexo generate` is executed is `/home/searene/Development/hexo-twenty-sixteen` in this tutorial.

First, we can find the location of the tool `hexo` with the command `which`.

``` shell
which hexo
```

My output is

``` shell
/home/searene/.nvm/versions/node/v5.0.0/bin/hexo
```

This is a soft link, we get the location of the original file with `ll`

``` shell
ll ~/.nvm/versions/node/v5.0.0/bin/hexo 

lrwxrwxrwx 1 searene searene 37 May 24 01:15 /home/searene/.nvm/versions/node/v5.0.0/bin/hexo -> ../lib/node_modules/hexo-cli/bin/hexo
```

The contents of `hexo` are as follows.

``` javascript
#!/usr/bin/env node
'use strict';
require('../lib/hexo')();
```

It requires a js file called `hexo`, which is located in `/home/searene/.nvm/versions/node/v5.0.0/lib/node_modules/hexo-cli/lib/hexo.js` in my case. The beginning part of the file is as follows.

``` javascript
'use strict';

var chalk = require('chalk');
var tildify = require('tildify');
var pathFn = require('path');
var Promise = require('bluebird');
var Context = require('./context');
var findPkg = require('./find_pkg');
var goodbye = require('./goodbye');
var minimist = require('minimist');
var camelCaseKeys = require('hexo-util/lib/camel_case_keys');
```

It requires several packages.

1. `chalk` is used for colorful outputs,.
2. `tildify` is used to convert an absolute path to a tilde path:, like `/Users/sindresorhus/dev` → `~/dev`.
3. `context` is used to //TODO
4. `find_pkg` is used to find the local hexo directory that contains `node_modules`
5. `goodbye` is used to generate a random goodbye sentence.
6. `minimist` is used to parse argument options.
7. `camelCaseKeys` is used to convert keys in parameters to the camelCased ones

Let's continue to read the file.

``` javascript
function entry(cwd, args) {
  // cwd is the directory where you invoked the node command
  cwd = cwd || process.cwd();
  // the keys in args is camelCased
  args = camelCaseKeys(args || minimist(process.argv.slice(2)));

  var hexo = new Context(cwd, args);
  var log = hexo.log;

  // Change the title in console
  process.title = 'hexo';

  function handleError(err) {
    log.fatal(err);
    process.exit(2);
  }
  /* findPkg searched upwards from the working directory(cwd) to
     find a directory containing package.json where the key hexo lies,
     a promise is returned by the function. */
  return findPkg(cwd, args).then(function(path) {
    if (!path) return;

    /* hexo.base_dir is set as the found directory, which is 
       /home/searene/Development/hexo-twenty-sixteen */
    hexo.base_dir = path;

    /* loadModule loads the hexo package located in the working
       directory(/home/searene/Development/hexo-twenty-sixteen)
       and returns a promise, the resolve function will carry a
       newly-constructed Hexo(return new Hexo(path, args)) object 
       afterwards. From now on, local hexo will be used instead 
       of the global one. */
    return loadModule(path, args).catch(function() {
      log.error('Local hexo not found in %s', chalk.magenta(tildify(path)));
      log.error('Try running: \'npm install hexo --save\'');
      process.exit(2);
    });
  }).then(function(mod) {
    if (mod) hexo = mod;
    log = hexo.log;

    require('./console')(hexo);

    return hexo.init();
  }).then(function() {
    var cmd = '';

    if (!args.h && !args.help) {
      cmd = args._.shift();

      if (cmd) {
        var c = hexo.extend.console.get(cmd);
        if (!c) cmd = 'help';
      } else {
        cmd = 'help';
      }
    } else {
      cmd = 'help';
    }

    watchSignal(hexo);

    return hexo.call(cmd, args).then(function() {
      return hexo.exit();
    }).catch(function(err) {
      return hexo.exit(err).then(function() {
        handleError(err);
      });
    });
  }).catch(handleError);
}

entry.console = {
  init: require('./console/init'),
  help: require('./console/help'),
  version: require('./console/version')
};

entry.version = require('../package.json').version;

function loadModule(path, args) {
  return Promise.try(function() {
    var modulePath = pathFn.join(path, 'node_modules', 'hexo');
    var Hexo = require(modulePath);

    return new Hexo(path, args);
  });
}

function watchSignal(hexo) {
  process.on('SIGINT', function() {
    hexo.log.info(goodbye());
    hexo.unwatch();

    hexo.exit().then(function() {
      process.exit();
    });
  });
}

module.exports = entry;
```

Notice the last part

``` javascript
module.exports = entry;
```

Remember the contents of `hexo.js`?

``` javascript
require('../lib/hexo')();
```

So what `hexo.js` does is calling the `entry` function. Here comes the question, what does `entry` do?

1. It searched upwards from the working directory looking for `package.json` containing the key `hexo`.

    ``` javascript
    function findPkg(cwd, args) {
      args = args || {};
    
      if (args.cwd) {
        cwd = pathFn.resolve(cwd, args.cwd);
      }
    
      return checkPkg(cwd);
    }
    
    function checkPkg(path) {
      var pkgPath = pathFn.join(path, 'package.json');
    
      return fs.readFile(pkgPath).then(function(content) {
        var json = JSON.parse(content);
        if (typeof json.hexo === 'object') return path;
      }).catch(function(err) {
        if (err && err.cause.code === 'ENOENT') {
          var parent = pathFn.dirname(path);
    
          if (parent === path) return;
          return checkPkg(parent);
        }
    
        throw err;
      });
    }
    ```

2.  Then it loads the local hexo package.

    ``` javascript
    function loadModule(path, args) {
      return Promise.try(function() {
        var modulePath = pathFn.join(path, 'node_modules', 'hexo');
        var Hexo = require(modulePath);
    
        return new Hexo(path, args);
      });
    }
    ```
3. `new` a `Hexo` object. The souce code of `Hexo` is as follows:

  ``` javascript
  function Hexo(base, args) {
    base = base || process.cwd();
    args = args || {};

    EventEmitter.call(this);

    this.base_dir = base + sep;
    this.public_dir = pathFn.join(base, 'public') + sep;
    this.source_dir = pathFn.join(base, 'source') + sep;
    this.plugin_dir = pathFn.join(base, 'node_modules') + sep;
    this.script_dir = pathFn.join(base, 'scripts') + sep;
    this.scaffold_dir = pathFn.join(base, 'scaffolds') + sep;
    this.theme_dir = pathFn.join(base, 'themes', defaultConfig.theme) + sep;
    this.theme_script_dir = pathFn.join(this.theme_dir, 'scripts') + sep;

    this.env = {
      args: args,
      debug: Boolean(args.debug),
      safe: Boolean(args.safe),
      silent: Boolean(args.silent),
      env: process.env.NODE_ENV || 'development',
      version: pkg.version,
      init: false
    };

    this.config_path = args.config ? pathFn.resolve(base, args.config)
                                   : pathFn.join(base, '_config.yml');

    this.extend = {
      console: new extend.Console(),
      deployer: new extend.Deployer(),
      filter: new extend.Filter(),
      generator: new extend.Generator(),
      helper: new extend.Helper(),
      migrator: new extend.Migrator(),
      processor: new extend.Processor(),
      renderer: new extend.Renderer(),
      tag: new extend.Tag()
    };

    this.config = _.cloneDeep(defaultConfig);

    this.log = logger(this.env);

    this.render = new Render(this);

    this.route = new Router();

    this.post = new Post(this);

    this.scaffold = new Scaffold(this);

    this._dbLoaded = false;

    this._isGenerating = false;

    this.database = new Database({
      version: dbVersion,
      path: pathFn.join(base, 'db.json')
    });

    registerModels(this);

    this.source = new Source(this);
    this.theme = new Theme(this);
    this.locals = new Locals(this);
    this._bindLocals();
  }
  ```

  `Hexo` gets several directories such as `public_dir`, `source_dir`, etc. Then it defines the `this.extend` object, which contains `console`, `deployer`, etc. The format of each instance in the `this.extend` object is as follows:

  ``` javascript
  function Console() {
    this.store = {};
    this.alias = {};
  }
  //-------------------------
  function Deployer() {
    this.store = {};
  }
  //-------------------------
  function Filter() {
    this.store = {};
  }
  //-------------------------
  function Generator() {
    this.id = 0;
    this.store = {};
  }
  //-------------------------
  function Helper() {
    this.store = {};
  }
  //-------------------------
  function Migrator() {
    this.store = {};
  }
  //-------------------------
  function Processor() {
    this.store = [];
  }
  //-------------------------
  function Renderer() {
    this.store = {};
    this.storeSync = {};
  }
  //-------------------------
  function Tag() {
    this.env = new nunjucks.Environment(null, {
      autoescape: false
    });
  }
  //-------------------------
  ```

  All of them contain the same object `this.store`, which is used to map the name to the corresponding function. For example, `this.store` in `Console` is as follows:

  ![this.store](http://i.imgur.com/fB0X6I3.png)

  Each key in the object such as `clean`, `config` is of type string. What they are mapped to are functions that implement them.

  Then it creates several instances, `logger`, `Render`, `Router`, `Post`, `Scaffold`, `database` etc. `logger` is used to log information on the console and the file, `Render` is used to render files(e.g. render markdownf files to html), `Router` is used to save all paths used in the site, `Post` is used to //TODO, `Scaffold` is used to //TODO, `database` is a [JSON-based database](https://github.com/tommy351/warehouse).

  It then registered following schemas using `registerModels(this)`.
  
  ``` javascript
  exports.Asset = require('./asset');
  exports.Cache = require('./cache');
  exports.Category = require('./category');
  exports.Data = require('./data');
  exports.Page = require('./page');
  exports.Post = require('./post');
  exports.PostAsset = require('./post_asset');
  exports.PostCategory = require('./post_category');
  exports.PostTag = require('./post_tag');
  exports.Tag = require('./tag');
  ```

  Afterwards, two instances are initiated, `Source`, `Theme`,which represents `source` and `theme` folders respectively. They are both being processed by `Box`.

  First, let's look at `source`.js.

  ``` javascript
  'use strict';

  var Box = require('../box');
  var util = require('util');

  function Source(ctx) {
    Box.call(this, ctx, ctx.source_dir);

    this.processors = ctx.extend.processor.list();
  }

  util.inherits(Source, Box);

  module.exports = Source;
  ```

  `ctx` refers to `Hexo`, `Source` function calls `Box` and gets the processor list, then it inherits `Box`. `Box` is used to read and render files in `source` or `theme` folder. To find out what's going on, we need to look into the source code of `Box`.

  ``` javascript
    function Box(ctx, base, options) {
      EventEmitter.call(this);

      this.options = _.assign({
        persistent: true
      }, options);

      // if the last character of the working directory 
      // is not /, add it to the end of base
      if (base.substring(base.length - 1) !== sep) {
        base += sep;
      }

      this.context = ctx;
      this.base = base;
      this.processors = [];
      this._processingFiles = {};
      this.watcher = null;
      this.Cache = ctx.model('Cache');
      this.File = this._createFileClass();
    }
  ```

  It sets several variables, then it gets the `Cache` model. The source code of `ctx.model` function is as follows.

  ``` javascript
    Hexo.prototype.model = function(name, schema) {
    return this.database.model(name, schema);
  };
  ```

  If the model was created before, `this.database.model` will just return the model, or it will create the model with the specified `name` and `schema`.

  ``` javascript
    Database.prototype.model = function(name, schema) {
      if (this._models[name]) {
        return this._models[name];
      }

      var model = this._models[name] = new this.Model(name, schema);
      return model;
    };
  ```

  Note that We have created the model in the `register_model` function, which is located in the `Hexo` function. When the code `new Hexo` is run, all the models are registered.

  ``` javascript
  'use strict';

  var models = require('../models');

  module.exports = function(ctx) {
    var db = ctx.database;

    var keys = Object.keys(models);
    var key = '';

    for (var i = 0, len = keys.length; i < len; i++) {
      key = keys[i];
      db.model(key, models[key](ctx));
    }
  };
  ```

  The models created here were as follows.

  ``` javascript
  'use strict';

  exports.Asset = require('./asset');
  exports.Cache = require('./cache');
  exports.Category = require('./category');
  exports.Data = require('./data');
  exports.Page = require('./page');
  exports.Post = require('./post');
  exports.PostAsset = require('./post_asset');
  exports.PostCategory = require('./post_category');
  exports.PostTag = require('./post_tag');
  exports.Tag = require('./tag');
  ```

  Which includes `cache`. So we can get the created `cache` model with `this.Cache = ctx.model('Cache');`. This model is used to cache generated posts and stuff, and store a hashed value for all of them. If the hash value is identical, hexo will not generate the post again, which reduces the generation time to a degree.

  Now we only have a line left in the `box` function.

  ``` javascript
  this.File = this._createFileClass();
  ```

  `this.File` is used to read file contents and render it. The source code of `_createFileClass()` function is as follows.

  ``` javascript
  Box.prototype._createFileClass = function() {
    //ctx is Hexo
    var ctx = this.context;

    var _File = function(data) {
      File.call(this, data);
    };

    require('util').inherits(_File, File);

    _File.prototype.box = this;

    _File.prototype.render = function(options, callback) {
      if (!callback && typeof options === 'function') {
        callback = options;
        options = {};
      }

      return ctx.render.render({
        path: this.source
      }, options).asCallback(callback);
    };

    _File.prototype.renderSync = function(options) {
      return ctx.render.renderSync({
        path: this.source
      }, options);
    };

    return _File;
  };
  ```

  `File.call(this, data)` sets `_File`'s `source`, `path`, `params` and `type` as the same as ones in `data`. You can see it in the source of the `File` constructor.

  ``` javascript
  function File(data) {
    this.source = data.source;
    this.path = data.path;
    this.params = data.params;
    this.type = data.type;
  }
  ```

  `_File` inherits `File` afterwards. Then it sets `render` and `renderSync` function of `_File` and returns it. As you can tell from their names, they are used to render files or strings, like this:

  ``` javascript
  hexo.render.render({text: 'example', engine: 'swig'}).then(function(result){
    // ...
  });
  ```

  ``` javascript
  hexo.render.render({path: 'path/to/file.swig'}).then(function(result){
    // ...
  });
  ```

  ## Render

  Let's look into the `Render` object.

  ``` javascript
  function Render(ctx) {
    this.context = ctx;
    this.renderer = ctx.extend.renderer;
  }
  ```

  Still remember `renderer`? It's used to store all the information about rendering.

  ``` javascript
  function Renderer() {
    this.store = {};
    this.storeSync = {};
  }
  ```

  The most important function in `render.js` is `Render.prototype.render`, the function is used to render text or files, the source code of it is as follows.

  ``` javascript
  Render.prototype.render = function(data, options, callback) {
    if (!callback && typeof options === 'function') {
      callback = options;
      options = {};
    }

    var ctx = this.context;
    var self = this;
    var ext = '';

    return new Promise(function(resolve, reject) {
      if (!data) return reject(new TypeError('No input file or string!'));
      if (data.text != null) return resolve(data.text);
      if (!data.path) return reject(new TypeError('No input file or string!'));

      fs.readFile(data.path).then(resolve, reject);
    }).then(function(text) {
      data.text = text;
      ext = data.engine || getExtname(data.path);
      if (!ext || !self.isRenderable(ext)) return text;

      var renderer = self.getRenderer(ext);
      return renderer.call(ctx, data, options);
    }).then(function(result) {
      result = toString(result, data);
      if (data.onRenderEnd) {
        return data.onRenderEnd(result);
      }

      return result;
    }).then(function(result) {
      var output = self.getOutput(ext) || ext;
      return ctx.execFilter('after_render:' + output, result, {
        context: ctx,
        args: [data]
      });
    }).asCallback(callback);
  };
  ```
    
  * First, it checks if `data` exists or not, `data` contains text(`data.text`) or file(`data.path`) that is going to be rendered, it throws an error if it doesn't exist.
    
    ``` javascript
    if (!data) return reject(new TypeError('No input file or string!'));
    ```

  * Then if `data.text` exists, it will try to render the text first.

    ``` javascript
    if (data.text != null) return resolve(data.text);
    ```

  * If `data.path` exists, it will try to analyze the file specified by `data.path`.

    ``` javascript
    if (!data.path) return reject(new TypeError('No input file or string!'));
    fs.readFile(data.path).then(resolve, reject);
    ```

  * It tries to find out if the rendering engine exists in `renderer.store`, which maps the rendering engine's name to the corresponding rendering function. If the engine exists, it will call the corresponding function to render it, return the original text if the engine doesn't exist.

    ``` javascript
    }).then(function(text) {
    data.text = text;
    ext = data.engine || getExtname(data.path);
    if (!ext || !self.isRenderable(ext)) return text;

    // get the function used to render
    var renderer = self.getRenderer(ext);
    return renderer.call(ctx, data, options);
    ```

    `renderer` refers to the function that is used to render text or files. What `renderer.call()` returns is usually of JSON format. For example, if the file to be rendered is like this:

    ``` javascript
    archive_dir: archives
    author: John Doe
    ```

    The rendered result will be an object like this:

    ``` javascript
    {archive_dir: "archives", author: "John Doe"}
    ```

    Some files are not rendered in this way, e.g. `md`. The rendering results of markdown files are of type string. `Hexo` creates a `toString` function to make the conversion happen.

    ``` javascript
    result = toString(result, data);
    ```

    The source code of `toString` function is as follows.

    ``` javascript
    function toString(result, options) {
      if (!options.hasOwnProperty('toString') || typeof result === 'string') return result;

      if (typeof options.toString === 'function') {
        return options.toString(result);
      } else if (typeof result === 'object') {
        return JSON.stringify(result);
      } else if (result.toString) {
        return result.toString();
      }

      return result;
    }
    ```

    Because `md` files's rendering results are of type string. so `toString` returns the original result directly in this case. Sometimes it needs to be further processed.

    Afterwards, `onRenderEnd` is followed in order to modify some contents of `result` after rendering.

    ``` javascript
    if (data.onRenderEnd) {
      return data.onRenderEnd(result);
    }
    ```

    Then the result is transferred to the next `then` function, and the `after_render` filter is executed.

    ``` javascript
    }).then(function(result) {
      // output is the file's final type, e.g. html, css
      // the result of self.getOutput('md') would be 'html',
      // because the rendering result of a markdown file is of type html
      var output = self.getOutput(ext) || ext;
      return ctx.execFilter('after_render:' + output, result, {
        context: ctx,
        args: [data]
      });
    }).asCallback(callback);
    ```

    To make it even clearer about how to use `execFilter`, Here I give an example from the official Hexo website, the following code is used to uglify js files.

      ``` javascript
    var UglifyJS = require('uglify-js');

    hexo.extend.filter.register('after_render:js', function(str, data){
      var result = UglifyJS.minify(str);
      return result.code;
    });
      ```

    This is the source code of `register` function.

    ``` javascript
    Filter.prototype.register = function(type, fn, priority) {
      if (!priority) {
        if (typeof type === 'function') {
          priority = fn;
          fn = type;
          type = 'after_post_render';
        }
      }

      if (typeof fn !== 'function') throw new TypeError('fn must be a function');

      type = typeAlias[type] || type;
      priority = priority == null ? 10 : priority;

      var store = this.store[type] = this.store[type] || [];

      fn.priority = priority;
      store.push(fn);

      store.sort(function(a, b) {
        return a.priority - b.priority;
      });
    };
    ```

    As you can see, it stores `type`(e.g. `after_post_render:js`) and the corresponding processing function in the `this.store` object. After the registration is over, `Filter.prototype.exec` executes the specified filter (`after_post_render:js` in this case).

    ``` javascript
    Filter.prototype.exec = function(type, data, options) {
      options = options || {};

      // filters are the functions that are registered before.
      // this.list(type) gets these functions from this.store
      var filters = this.list(type);
      var ctx = options.context;
      var args = options.args || [];

      args.unshift(data);

      return Promise.each(filters, function(filter) {
        return Promise.method(filter).apply(ctx, args).then(function(result) {
          /* when the processing is over, the processing function returns
             the processed result, if the result equals null, it will return
             the original one without processed by the filter(data), if the
             result is not null, it will return the result processed by the
             filter */
          args[0] = result == null ? data : result;
          return args[0];
        });
      }).then(function() {
        return args[0];
      });
    };
  ```

    OK, this part is over, let's look into the `theme/index.js` file next.

    ``` javascript
    'use strict';

    var pathFn = require('path');
    var util = require('util');
    var Box = require('../box');
    var View = require('./view');
    var I18n = require('hexo-i18n');
    var _ = require('lodash');

    function Theme(ctx) {
      Box.call(this, ctx, ctx.theme_dir);

      this.config = {};

      this.views = {};

      this.processors = [
        require('./processors/config'),
        require('./processors/i18n'),
        require('./processors/source'),
        require('./processors/view')
      ];

      var languages = ctx.config.language;

      if (!Array.isArray(languages)) {
        languages = [languages];
      }

      languages.push('default');

      this.i18n = new I18n({
        languages: _(languages).compact().uniq().value()
      });

      var _View = this.View = function(path, data) {
        View.call(this, path, data);
      };

      util.inherits(_View, View);

      _View.prototype._theme = this;
      _View.prototype._render = ctx.render;
      _View.prototype._helper = ctx.extend.helper;
    }

    util.inherits(Theme, Box);
    ```

    The function `Theme` also calls `Box()`, then it adds several processors and sets languages and views.

    Then it bind locals.

    ``` javascript
    Hexo.prototype._bindLocals = function() {
    var db = this.database;
    var locals = this.locals;
    var self = this;

    locals.set('posts', function() {
      var query = {};

      if (!self.config.future) {
        query.date = {$lte: Date.now()};
      }

      if (!self._showDrafts()) {
        query.published = true;
      }

      return db.model('Post').find(query);
    });

    locals.set('pages', function() {
      var query = {};

      if (!self.config.future) {
        query.date = {$lte: Date.now()};
      }

      return db.model('Page').find(query);
    });

    locals.set('categories', function() {
      return db.model('Category');
    });

    locals.set('tags', function() {
      return db.model('Tag');
    });

    locals.set('data', function() {
      var obj = {};

      db.model('Data').forEach(function(data) {
        obj[data._id] = data.data;
      });

      return obj;
    });
  };
```

4. After loading module is over, it calls `console` to execute the provided command
  
  ``` javascript
  return loadModule(path, args).catch(function() {
      log.error('Local hexo not found in %s', chalk.magenta(tildify(path)));
      log.error('Try running: \'npm install hexo --save\'');
      process.exit(2);
    });
  }).then(function(mod) {
    if (mod) hexo = mod;
    log = hexo.log;

    require('./console')(hexo);

    return hexo.init();
  ```
  
  Let's look through the source code of `./console`.
  
  ``` javascript
  'use strict';

  module.exports = function(ctx) {
    var console = ctx.extend.console;

    console.register('help', 'Get help on a command.', {
    }, require('./help'));

    console.register('init', 'Create a new Hexo folder.', {
    desc: 'Create a new Hexo folder at the specified path or the current directory.',
    usage: '[destination]',
    arguments: [
      {name: 'destination', desc: 'Folder path. Initialize in current folder if not specified'}
    ],
    options: [
      {name: '--no-clone', desc: 'Copy files instead of cloning from GitHub'},
      {name: '--no-install', desc: 'Skip npm install'}
    ]
    }, require('./init'));

    console.register('version', 'Display version information.', {
    }, require('./version'));
  };
  ```
  
  It registers several commands using `console.register`, let's look through its source code.
  
  ``` javascript
  Console.prototype.register = function(name, desc, options, fn) {
    if (!name) throw new TypeError('name is required');

    if (!fn) {
      if (options) {
        if (typeof options === 'function') {
          fn = options;

          if (typeof desc === 'object') { // name, options, fn
            options = desc;
            desc = '';
          } else { // name, desc, fn
            options = {};
          }
        } else {
          throw new TypeError('fn must be a function');
        }
      } else {
        // name, fn
        if (typeof desc === 'function') {
          fn = desc;
          options = {};
          desc = '';
        } else {
          throw new TypeError('fn must be a function');
        }
      }
    }

    if (fn.length > 1) {
      fn = Promise.promisify(fn);
    } else {
      fn = Promise.method(fn);
    }

    var c = this.store[name.toLowerCase()] = fn;
    c.options = options;
    c.desc = desc;

    this.alias = abbrev(Object.keys(this.store));
  };
  ```

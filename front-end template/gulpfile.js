var gulp        = require('gulp');
var minifyCss   = require('gulp-minify-css');
// var coffee      = require('gulp-coffee');
var sass        = require('gulp-sass');
var notify      = require('gulp-notify');
var browserSync = require('browser-sync');
var nodemon     = require('gulp-nodemon');
var rename      = require('gulp-rename');
var autoprefixer = require('gulp-autoprefixer')
var del         = require('del');
var reload      = browserSync.reload;

var paths = {
    jade:['app/views/*.jade'],
    html:['app/views/*.html'],
    scss:['app/scss/*.scss'],
    // script:['script.coffee']
};

gulp.task('mincss', function(){
    return gulp.src(paths.scss)
        .pipe(sass().on('error', sass.logError))
        .pipe(rename({suffix:'.min'}))
        .pipe(autoprefixer('last 2 version', 'safari 5', 'ie 8', 'ie 9'))
        .pipe(minifyCss())
        .pipe(gulp.dest('app/public/css'))
        .pipe(reload({stream:true}));
});

// ////////////////////////////////////////////////
// HTML task
// ///////////////////////////////////////////////

gulp.task('html', function(){
    gulp.src(paths.html)
    .pipe(reload({stream:true}));
});

// ////////////////////////////////////////////////
// Browser-Sync Tasks
// // /////////////////////////////////////////////

gulp.task('browser-sync', ['nodemon'], function () {
  browserSync.init({
    proxy: 'http://localhost:3000',
    files: ['app/public/**/*.*', 'app/views/**/*.*'],
    //browser: 'google chrome',
    notify: false,
    port: 5000
  });
});

gulp.task('nodemon', function (cb) {
  var called = false;

  return nodemon({
    script: 'app/bin/www'
  }).on('start', function () {
    if (!called) {
      cb();
      called = true;
    }
  });
});

// gulp.task('scripts', function(){
//     return gulp.src(paths.script)
//         .pipe(coffee())
//         .pipe(gulp.dest('js'))
//         .pipe(reload({stream:true}));
// });

gulp.task('watch',function(){
    gulp.watch(paths.scss, ['mincss']);
    // gulp.watch(paths.script, ['scripts']);
    gulp.watch(paths.html, ['html']);
});

gulp.task('default', ['watch', 'browser-sync']);
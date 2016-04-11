var gulp = require('gulp');
var minifyCss = require('gulp-minify-css');
var sass = require('gulp-sass');
var notify = require('gulp-notify');
var browserSync = require('browser-sync');
var nodemon = require('gulp-nodemon');
var rename = require('gulp-rename');
var autoprefixer = require('gulp-autoprefixer')
var del = require('del');
var reload = browserSync.reload;

var paths = {
    jade: ['views/*.jade'],
    scss: ['scss/*.scss'],
    // script:['script.coffee']
};

gulp.task('css', function () {
    return gulp.src(paths.scss)
        .pipe(sass().on('error', sass.logError))
        .pipe(autoprefixer('last 2 version', 'safari 5', 'ie 8', 'ie 9'))
        .pipe(gulp.dest('public/css'))
        .pipe(reload({stream: true}));
});
gulp.task('mincss', function () {
    return gulp.src(paths.scss)
        .pipe(sass().on('error', sass.logError))
        .pipe(rename({suffix: '.min'}))
        .pipe(autoprefixer('last 2 version', 'safari 5', 'ie 8', 'ie 9'))
        .pipe(minifyCss())
        .pipe(gulp.dest('public/css'))
        .pipe(reload({stream: true}));
});

// we'd need a slight delay to reload browsers
// connected to browser-sync after restarting nodemon
var BROWSER_SYNC_RELOAD_DELAY = 500;

gulp.task('nodemon', function (cb) {
    var called = false;
    return nodemon({

        // nodemon our expressjs server
        script: 'bin/www',

        // watch core server file(s) that require server restart on change
        watch: ['bin/www']
    })
        .on('start', function onStart() {
            // ensure start only got called once
            if (!called) {
                cb();
            }
            called = true;
        })
        .on('restart', function onRestart() {
            // reload connected browsers after a slight delay
            setTimeout(function reload() {
                reload({
                    stream: false
                });
            }, BROWSER_SYNC_RELOAD_DELAY);
        });
});

// ////////////////////////////////////////////////
// Browser-Sync Tasks
// // /////////////////////////////////////////////

gulp.task('browser-sync', ['nodemon'], function () {
    browserSync.init({
        proxy: 'http://localhost:3456',
        files: ['public/css/*.css', 'public/js/*.js', 'views/*.jade'],
        notify: false,
        port: 5678
    });
});

//gulp.task('jade', function() {
//    gulp.src('./views/index.jade')
//        .pipe(jade({
//            pretty: true
//        }))
//        .pipe(gulp.dest('./public/'))
//        .pipe(reload({stream:true}));
//});
// gulp.task('scripts', function(){
//     return gulp.src(paths.script)
//         .pipe(coffee())
//         .pipe(gulp.dest('js'))
//         .pipe(reload({stream:true}));
// });

gulp.task('watch', function () {
    gulp.watch(paths.scss, ['mincss', 'css']);
});

gulp.task('default', ['watch', 'browser-sync']);

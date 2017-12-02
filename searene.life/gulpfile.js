var gulp = require('gulp');
var bs = require('browser-sync').create(); // create a browser sync instance.

gulp.task('browser-sync', function() {
    bs.init({
        proxy: {
            target: "localhost:4000",
            ws: true
        }
    });
});

gulp.task('watch', ['browser-sync'], function () {
    gulp.watch("source/**/*").on('change', bs.reload);
});

gulp.task('default', ['browser-sync', 'watch'])

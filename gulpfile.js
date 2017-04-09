'use strict';

const gulp = require('gulp');
const elm  = require('gulp-elm');
const sass = require('gulp-sass');

gulp.task('elm-init', elm.init);

gulp.task('elm', ['elm-init'], () => {
  return gulp.src('src/*.elm')
    .pipe(elm({ filetype: 'js' }))
    .pipe(gulp.dest('dist/js/'));
});

gulp.task('sass', () => {
  return gulp.src('./src/scss/**/*.scss')
    .pipe(sass().on('error', sass.logError))
    .pipe(gulp.dest('./dist/css'));
});

gulp.task('watch', function () {
  gulp.watch('./src/*.elm', ['elm']);
  gulp.watch('./src/scss/**/*.scss', ['sass']);
});

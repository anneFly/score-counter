'use strict';

(function (window) {
  window.onload = function () {
    var app = Elm.Main.fullscreen();
    var audio = document.getElementById('sound-effect');

    app.ports.playSound.subscribe(function (sound) {
      if (sound === 'on') {
        audio.play();
      }
    });
  };

  window.activateFullscreen = function () {
    var element = document.querySelector('.app');
    if (element.requestFullscreen) {
      element.requestFullscreen();
    } else if (element.webkitRequestFullscreen) {
      element.webkitRequestFullscreen();
    } else if (element.mozRequestFullScreen) {
      element.mozRequestFullScreen();
    } else if (element.msRequestFullscreen) {
      element.msRequestFullscreen();
    }
  };

  window.deactivateFullscreen = function () {
    if (document.exitFullscreen) {
      document.exitFullscreen();
    } else if (document.webkitExitFullscreen) {
      document.webkitExitFullscreen();
    } else if (document.mozCancelFullScreen) {
      document.mozCancelFullScreen();
    } else if (document.msExitFullscreen) {
      document.msExitFullscreen();
    }
  };
}(window));

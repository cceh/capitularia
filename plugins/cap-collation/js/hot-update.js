webpackHotUpdate("app",{

/***/ "./src/js/main.js":
/*!************************!*\
  !*** ./src/js/main.js ***!
  \************************/
/*! no exports provided */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
eval("__webpack_require__.r(__webpack_exports__);\n/* harmony import */ var main_vue__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! main.vue */ \"./src/js/main.vue\");\n // wrapper to call the Wordpress translate function\n// See: https://make.wordpress.org/core/2018/11/09/new-javascript-i18n-support-in-wordpress/\n\nfunction $t(text) {\n  return wp.i18n.__(text, 'cap-collation');\n} // the vm.$t function\n\n\nVue.prototype.$t = function (text) {\n  return $t(text);\n}; // the v-translate directive\n\n\nVue.directive('translate', function (el) {\n  el.innerText = $t(el.innerText);\n}); // the {{ 'text' | translate }} filter\n\nVue.filter('translate', function (text) {\n  return $t(text);\n});\nvar app = new Vue({\n  el: '#cap-collation-app',\n  components: {\n    'cap-collation-app': main_vue__WEBPACK_IMPORTED_MODULE_0__[\"default\"]\n  }\n});//# sourceURL=[module]\n//# sourceMappingURL=data:application/json;charset=utf-8;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIndlYnBhY2s6Ly8vLi9zcmMvanMvbWFpbi5qcz85MjkxIl0sIm5hbWVzIjpbIiR0IiwidGV4dCIsIndwIiwiaTE4biIsIl9fIiwiVnVlIiwicHJvdG90eXBlIiwiZGlyZWN0aXZlIiwiZWwiLCJpbm5lclRleHQiLCJmaWx0ZXIiLCJhcHAiLCJjb21wb25lbnRzIiwiTWFpbiJdLCJtYXBwaW5ncyI6IkFBQUE7QUFBQTtDQUVBO0FBQ0E7O0FBQ0EsU0FBU0EsRUFBVCxDQUFhQyxJQUFiLEVBQW1CO0FBQ2YsU0FBT0MsRUFBRSxDQUFDQyxJQUFILENBQVFDLEVBQVIsQ0FBWUgsSUFBWixFQUFrQixlQUFsQixDQUFQO0FBQ0gsQyxDQUVEOzs7QUFDQUksR0FBRyxDQUFDQyxTQUFKLENBQWNOLEVBQWQsR0FBbUIsVUFBVUMsSUFBVixFQUFnQjtBQUMvQixTQUFPRCxFQUFFLENBQUVDLElBQUYsQ0FBVDtBQUNILENBRkQsQyxDQUlBOzs7QUFDQUksR0FBRyxDQUFDRSxTQUFKLENBQWUsV0FBZixFQUE0QixVQUFVQyxFQUFWLEVBQWM7QUFDdENBLElBQUUsQ0FBQ0MsU0FBSCxHQUFlVCxFQUFFLENBQUVRLEVBQUUsQ0FBQ0MsU0FBTCxDQUFqQjtBQUNILENBRkQsRSxDQUlBOztBQUNBSixHQUFHLENBQUNLLE1BQUosQ0FBWSxXQUFaLEVBQXlCLFVBQVVULElBQVYsRUFBZ0I7QUFDckMsU0FBT0QsRUFBRSxDQUFFQyxJQUFGLENBQVQ7QUFDSCxDQUZEO0FBSUEsSUFBTVUsR0FBRyxHQUFHLElBQUlOLEdBQUosQ0FBUztBQUNqQkcsSUFBRSxFQUFFLG9CQURhO0FBRWpCSSxZQUFVLEVBQUU7QUFDUix5QkFBc0JDLGdEQUFJQTtBQURsQjtBQUZLLENBQVQsQ0FBWiIsImZpbGUiOiIuL3NyYy9qcy9tYWluLmpzLmpzIiwic291cmNlc0NvbnRlbnQiOlsiaW1wb3J0IE1haW4gZnJvbSAnbWFpbi52dWUnXG5cbi8vIHdyYXBwZXIgdG8gY2FsbCB0aGUgV29yZHByZXNzIHRyYW5zbGF0ZSBmdW5jdGlvblxuLy8gU2VlOiBodHRwczovL21ha2Uud29yZHByZXNzLm9yZy9jb3JlLzIwMTgvMTEvMDkvbmV3LWphdmFzY3JpcHQtaTE4bi1zdXBwb3J0LWluLXdvcmRwcmVzcy9cbmZ1bmN0aW9uICR0ICh0ZXh0KSB7XG4gICAgcmV0dXJuIHdwLmkxOG4uX18gKHRleHQsICdjYXAtY29sbGF0aW9uJyk7XG59XG5cbi8vIHRoZSB2bS4kdCBmdW5jdGlvblxuVnVlLnByb3RvdHlwZS4kdCA9IGZ1bmN0aW9uICh0ZXh0KSB7XG4gICAgcmV0dXJuICR0ICh0ZXh0KTtcbn07XG5cbi8vIHRoZSB2LXRyYW5zbGF0ZSBkaXJlY3RpdmVcblZ1ZS5kaXJlY3RpdmUgKCd0cmFuc2xhdGUnLCBmdW5jdGlvbiAoZWwpIHtcbiAgICBlbC5pbm5lclRleHQgPSAkdCAoZWwuaW5uZXJUZXh0KTtcbn0pO1xuXG4vLyB0aGUge3sgJ3RleHQnIHwgdHJhbnNsYXRlIH19IGZpbHRlclxuVnVlLmZpbHRlciAoJ3RyYW5zbGF0ZScsIGZ1bmN0aW9uICh0ZXh0KSB7XG4gICAgcmV0dXJuICR0ICh0ZXh0KTtcbn0pO1xuXG5jb25zdCBhcHAgPSBuZXcgVnVlICh7XG4gICAgZWw6ICcjY2FwLWNvbGxhdGlvbi1hcHAnLFxuICAgIGNvbXBvbmVudHM6IHtcbiAgICAgICAgJ2NhcC1jb2xsYXRpb24tYXBwJyA6IE1haW4sXG4gICAgfSxcbn0pO1xuIl0sInNvdXJjZVJvb3QiOiIifQ==\n//# sourceURL=webpack-internal:///./src/js/main.js\n");

/***/ })

})
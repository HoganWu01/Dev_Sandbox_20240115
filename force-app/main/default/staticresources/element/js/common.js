/**
 * Created by Luby on 2018/11/5.
 */
function getQueryString(str) {
  var reg = new RegExp('(^|&)' + str + '=([^&]*)(&|$)', 'i');
  var result = window.location.search.substr(1).match(reg);
  var hash = window.location.hash;
  if (hash.length > 0) {
    var hashSpArr = hash.split('?');
    result = hashSpArr.length > 1 ? ('?' + hashSpArr[1]).substr(1).match(reg) : null;
  }
  if (result !== null) {
    return result[2];
  }
  return null;
}
// alert('sss')
// 加载js的方法
function loaderJs(src) {
  // "https://svn.veevlink.com/Custom/chengjia/boys/res/html/orderQuery.js"
  var new_element = document.createElement("script");
  new_element.setAttribute("type", "text/javascript");
  new_element.setAttribute("src", src);
  document.body.appendChild(new_element);
}
// 加载css的方法
function loaderCss(src) {
  // "https://svn.veevlink.com/Custom/chengjia/boys/res/html/orderQuery.js"
  var new_element = document.createElement("link");
  new_element.setAttribute("rel", "stylesheet");
  new_element.setAttribute("href", src);
  document.body.appendChild(new_element);
}
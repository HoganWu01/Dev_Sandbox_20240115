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


function getData(result, event,callback){
  if(event.status) {
    var data = eval("(" + result.replace(new RegExp('&quot;', "gm"), '\"') + ")");
    if(data.success){
      callback(data);
    }else{
      if(vm.$alert){
        vm.$alert(JSON.stringify(data), '错误提示', {
          confirmButtonText: '确定'
        });
      }else{
        alert(JSON.stringify(data))
      }
    }
  } else {
    if(vm.$alert){
      vm.$alert('系统有点问题,请稍后重试', '错误提示', {
        confirmButtonText: '确定'
      });
    }else{
      alert('系统有点问题,请稍后重试')
    }
  }
}

/*时间处理方法  可以为yyyy-MM-dd-hh-mm-ss*/
function formatDate(date, fmt) {
  if (/(y+)/.test(fmt)) {
    fmt = fmt.replace(RegExp.$1, (date.getFullYear() + '').substr(4 - RegExp.$1.length));
  }
  let o = {
    'M+': date.getMonth() + 1,
    'd+': date.getDate(),
    'h+': date.getHours(),
    'm+': date.getMinutes(),
    's+': date.getSeconds()
  };
  for (let k in o) {
    if (new RegExp(`(${k})`).test(fmt)) {
      let str = o[k] + '';
      fmt = fmt.replace(RegExp.$1, (RegExp.$1.length === 1) ? str : padLeftZero(str));
    }
  }
  return fmt;
};

function padLeftZero(str) {
  return ('00' + str).substr(str.length);
}

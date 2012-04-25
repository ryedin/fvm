var https = require("https"),
    path = require("path"),
    env = process.env;

var installCheck = function(tag) {
  if (path.existsSync(env.FVM_DIR + "/" + tag.trim())) {
    var color = "1;34m";
    if (isTagInUse(tag)) {
      color = "1;32m";
    }
    return "\033[" + color + tag + "\033[0m";
  }
  return tag;
}
var isTagInUse = function(tag) {
  if (env.FEATHER_HOME === env.FVM_DIR + "/" + tag.trim()) {
    return true;
  }
  return false;
}
var getMaxTagNameLength = function(tags) {
  var max = 0;
  tags.forEach(function(item) {
    if (item.length > max) max = item.length;
  });
  return max;
}

var padRight = function(str, len) {
  while (str.length < len) {
    str += " ";
  }
  return str;
};

https.get({
  host: 'github.com',
  port: 443,
  path: '/api/v2/json/repos/show/theVolary/feather/tags'
}, function(res) {
  var tagDataBuf = "";
  res.setEncoding('utf8');
  res.on('data', function(chunk) {
    tagDataBuf += chunk;
  });
  res.on('end', function( ) {
    var tagData = JSON.parse(tagDataBuf);
    var tags = [];
    for (var tag in tagData.tags) { 
      tags.push(tag);
    }
    tags.sort();
    var width = getMaxTagNameLength(tags);
    var maxPerLine = Math.floor(120 / width);
    var line = "", i, j;
    
    console.log("Available Tags (\033[1;34mBlue\033[0m are installed, \033[1;32mGreen\033[0m is in use.)");
    
    for (i = 0; i < tags.length; i+= maxPerLine) {
      line = "";
      for(j = 0; j < maxPerLine; j++) {
        if (i+j < tags.length) {
          line += installCheck(padRight(tags[i+j], width)) + ' ';
        }
      } 
      console.log(line);
    }
  });
}).on('error', function(e) {
  console.log(e);
});

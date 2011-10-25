// Linkify plugin 
// Enhanced
(function($){
  var no_protocol = /(^|&lt;|\s)(www\..+?\..+?)(\s|&gt;|$)/g,
      with_protocol = /(^|&lt;|\s)(((https?|ftp):\/\/|mailto:).+?)(\s|&gt;|$)/g,
      twitter_user = /(^|\W)@(\w+)/g, 
      twitter_hash = /(^|\W)#(\w+)/g

      linkifyThis = function () {
        var childNodes = this.childNodes,
            i = childNodes.length;
        while(i--)
        {
          var n = childNodes[i];
          if (n.nodeType == 3) {
            var html = $.trim(n.nodeValue);
            if (html)
            {
              html = html.replace(/&/g, '&amp;')
                         .replace(/</g, '&lt;')
                         .replace(/>/g, '&gt;')
                         .replace(no_protocol, '$1<a href="http://$2">$2</a>$3')
                         .replace(with_protocol, '$1<a href="$2">$2</a>$5')
                         .replace(twitter_user, '$1<a href="http://twitter.com/#!/$2" target="_new">@$2</a>')
                         .replace(twitter_hash, '$1<a href="http://twitter.com/#search?q=$2" target="_new">#$2</a>');
              $(n).after(html).remove();
            }
          }
          else if (n.nodeType == 1  &&  !/^(a|button|textarea)$/i.test(n.tagName)) {
            linkifyThis.call(n);
          }
        }
      };

  $.fn.linkify = function () {
    return this.each(linkifyThis);
  };

})(jQuery);
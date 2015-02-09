# Nginx Configuration Snippets
A collection of useful Nginx configuration snippets inspired by
[.htaccess snippets](https://github.com/phanan/htaccess).

## Table of Contents
- [The Nginx Command](#the-nginx-command)
- [Rewrite and Redirection](#rewrite-and-redirection)
    - [Force www](#force-www)
    - [Force no-www](#force-no-www)
    - [Force HTTPS](#force-https)
    - [Force Trailing Slash](#force-trailing-slash)
    - [Redirect a Single Page](#redirect-a-single-page)
    - [Redirect an Entire Site](#redirect-an-entire-site)
    - [Redirect an Entire Sub Path](#redirect-an-entire-sub-path)
- [Reverse Proxy and Load Balance](#reverse-proxy-and-load-balance)
- [Performance](#performance)
    - [Contents Caching](#contents-caching)
    - [Gzip Compression](#gzip-compression)
    - [Open File Cache](#open-file-cache)
    - [SSL Cache](#ssl-cache)
    - [Upstream Keepalive](#upstream-keepalive)
- [Security](#security)
- [Miscellaneous](#miscellaneous)


## The Nginx Command
The `nginx` command can be used to perform some useful actions when Nginx is running.

- Get current Nginx version and its configured compiling parameters: `nginx -V`
- Test the current Nginx configuration file and / or check its location: `nginx -t`
- Reload the configuration without restarting Nginx: `nginx -s reload`


## Rewrite and Redirection

### Force www
The [right way](http://nginx.org/en/docs/http/converting_rewrite_rules.html)
is to define a separated server for the naked domain and redirect it.
```nginx
server {
    listen 80;
    server_name example.org;
    return 301 $scheme://www.example.org$request_uri;
}

server {
    listen 80;
    server_name www.example.org;
    ...
}
```

Note that this also works for HTTPS site since we are using the `$scheme` variable.

### Force no-www
Again, the [right way](http://nginx.org/en/docs/http/converting_rewrite_rules.html)
is to define a separated server for the naked domain and redirect it.
```nginx
server {
    listen 80;
    server_name example.org;
}

server {
    listen 80;
    server_name www.example.org;
    return 301 $scheme://example.org$request_uri;
}
```

### Force HTTPS
This is also handled by the 2 server blocks approach.
```nginx
server {
    listen 80;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;

    # let the browsers know that we only accept HTTPS
    add_header Strict-Transport-Security max-age=2592000;

    ...
}
```

### Force Trailing Slash
This configuration only add trailing slash to URL that does not contain a dot because you probably don't want to add that trailing slash to your static files.
[Source](http://stackoverflow.com/questions/645853/add-slash-to-the-end-of-every-url-need-rewrite-rule-for-nginx).
```nginx
rewrite ^([^.]*[^/])$ $1/ permanent;
```

### Redirect a Single Page
```nginx
server {
    location = /oldpage.html {
        return 301 http://example.org/newpage.html;
    }
}
```

### Redirect an Entire Site
```nginx
server {
    server_name old-site.com
    return 301 $scheme://new-site.com$request_uri;
}
```

### Redirect an Entire Sub Path
```nginx
location /old-site {
    rewrite ^/old-site/(.*) http://example.org/new-site/$1 permanent;
}
```


## Reverse Proxy and Load Balance


## Performance

### Contents Caching
Allow browsers to cache your static contents for basically forever. Nginx will set both `Expires` and `Cache-Control` header for you.
```nginx
location /static {
    root /data;
    expires max;
}
```

If you want to ask the browsers to **never** cache the response (e.g. for tracking requests), use `-1`.
```nginx
location = /empty.gif {
    empty_gif;
    expires -1;
}
```

### Gzip Compression
```nginx
gzip  on;
gzip_buffers 16 8k;
gzip_comp_level 6;
gzip_http_version 1.1;
gzip_min_length 256;
gzip_proxied any;
gzip_vary on;
gzip_types
    text/xml application/xml application/atom+xml application/rss+xml application/xhtml+xml image/svg+xml
    text/javascript application/javascript application/x-javascript
    text/x-json application/json application/x-web-app-manifest+json
    text/css text/plain text/x-component
    font/opentype application/x-font-ttf application/vnd.ms-fontobject
    image/x-icon;
gzip_disable  "msie6";
```

### Open File Cache
If you have _a lot_ of static files to serve through Nginx then caching of the files' metadata (not the actual files' contents) can save some latency.
```nginx
open_file_cache max=1000 inactive=20s;
open_file_cache_valid 30s;
open_file_cache_min_uses 2;
open_file_cache_errors on;
```

### SSL Cache
Enable SSL cache for SSL sessions resumption, so that sub sequent SSL/TLS connection handshakes can be shortened and reduce total SSL overhead.
```nginx
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
```

### Upstream Keepalive
Enable the upstream connection cache for better reuse of connections to upstream servers. [Source](http://nginx.org/en/docs/http/ngx_http_upstream_module.html#keepalive).
```nginx
upstream backend {
    server 127.0.0.1:8080;
    keepalive 32;
}

server {
    ...
    location /api/ {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
```


## Security


## Miscellaneous
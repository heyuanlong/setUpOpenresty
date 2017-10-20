# setUpOpenresty

##快速搭建指南
- 1.yum install readline-devel pcre-devel openssl-devel
- 2.wget https://openresty.org/download/openresty-1.11.2.1.tar.gz
- 3.tar -xzvf openresty-VERSION.tar.gz
- 4.cd openresty-VERSION/

- 5.执行命令./configure --prefix=/data/testnginx/openresty \
            --with-luajit \
            --without-http_redis2_module \
            --with-http_iconv_module

- 6.make && make install

- 7.mkdir -p /data/testnginx/lib/common;
>mkdir -p /data/testnginx/lib/connect;
>mkdir -p /data/testnginx/logs;
>mkdir -p /data/testnginx/sites-conf;
>mkdir -p /data/testnginx/data;

- 8.vim nginx.conf{
error_log   /data/testnginx/logs/error.log error;


lua_package_path "/data/testnginx/lib/?.lua;/data/testnginx/lib/?/init.lua;/data/testnginx/openresty/lualib/?.lua;";
lua_package_cpath "/data/testnginx/lib/?.so;/data/testnginx/openresty/lualib/?.so;";


include /data/testnginx/sites-conf/*;
}


- 9.testnginx.open.com/test1.do?gameID=1&userID=1
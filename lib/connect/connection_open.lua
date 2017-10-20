module("connect.connection_open", package.seeall)


local MYSQL                                 = require "resty.mysql"
local redis                                 = require "resty.redis"
local JSON                                  = require "common.json"

local mongo                                 = require "common.mongol"  



local redis_server_ip                       =   "127.0.0.1"
local redis_server_port                     =   6379
local redis_server_pass                     =   "xx"

local mysql_server_ip                       =   "127.0.0.1"
local mysql_server_port                     =   3306
local mysql_user_name                       =   "root"
local mysql_user_pass                       =   "xxxx"
local mysql_max_packet_size                 =   1024 * 1024

local mongo_server_ip                       =   "127.0.0.1"
local mongo_server_port                     =   27017
local mongo_db_event_user                   =   "USER"
local mongo_db_event_pass                   =   "XXX"


local redis_type                            =   1
local mysql_type                            =   2
local mongo_type                            =   4

function        getRedis()
    local red               = redis:new()
    local ok, err           = red:connect(redis_server_ip, redis_server_port)
    if not ok then
        return nil, err
    end
    local ok, err           = red:auth(redis_server_pass)
    if not ok then
        return nil, err
    end
    red:set_timeout(1000)
    return red,nil
end


function        getMysql(ext)
    local mysql             = MYSQL:new()
    local ok, err, errno, sqlstate = mysql:connect{
        host = mysql_server_ip,
        port = mysql_server_port,
        database = "test",
        user = mysql_user_name,
        password = mysql_user_pass,
	ext = ext,
        max_packet_size = mysql_max_packet_size,
        charset=utf8 }
    if not ok then
        return nil, err, errno, sqlstate
    end
     mysql:set_timeout(1000)
    return mysql,nil,nil,sqlstate
end

function        getMongo()
    local conn             = mongo:new()
    local ok, err = conn:connect(mongo_server_ip,mongo_server_port)
    if not ok then
        return nil, nil, err
    end

    local db = conn:new_db_handle(dbname)
    if not db then
        conn:close()
        return nil, nil,"no this mongo db"
    end
    return conn,db,nil
end


function       releaseConn( redisConn, mysqlConn, mongoConn)
    local ok = true
    local db_type = 0
    local err = ""
    if redisConn then
        local ok, err           = redisConn:set_keepalive(10000, 100)
        if not ok then
            redisConn:close()
            ok = false
            db_type = db_type + redis_type
            err = "Redis.Error ( "..(err or "null").." ) "
        end
    end
    if mysqlConn then
        local res, err, errno, sqlstate = mysqlConn:read_result()
        while err == "again" do
            res, err, errno, sqlstate = mysqlConn:read_result()
        end
        local ok, err           = mysqlConn:set_keepalive(10000, 100)
        if not ok then
            mysqlConn:close()
            ok = false
            db_type = db_type + mysql_type
            err = "MySQL.Error ( "..(err or "null").." ) "
        end
    end 
    if mongoConn then
        local ok, err           = mongoConn:set_keepalive(10000, 100)
        if not ok then
            mongoConn:close()
            ok = false
            db_type = db_type + mongo_type
            err = "Mongo.Error ( "..(err or "null").." ) "
        end
    end
    return ok, db_type, err
end

function releaseConns(conns, tags)
    for index,v in pairs(conns) do
        local ok, err           = v:set_keepalive(10000, 100)
        if not ok then
            v:close()
        end
    end
    return true, nil, nil
end